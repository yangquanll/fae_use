#include <linux/vmalloc.h>
#include <linux/uaccess.h>
#include <linux/errno.h>
#include <linux/mm.h>

#include <linux/tee_ioc.h>
#include "tee_core.h"

#include "tee_ta_mgmt.h"
#include "tee_shm.h"
#include "tee_supp_com.h"

static struct semaphore sem_inst_ta;
static struct mutex mutex_inst_ta;

int tee_install_sp_ta(struct tee_context *ctx, void __user *__tee_spta_inst_desc)
{
	struct tee_shm *shm_in = NULL;
	struct tee_shm *shm_out = NULL;

	struct tee *tee = ctx->tee;

	struct tee_rpc_invoke request;
	struct tee_spta_inst_desc ta;

	uint32_t response_len = 0;
	uint32_t response_msg_len = 0;

	int ret = 0;

	if (ctx == NULL || __tee_spta_inst_desc == NULL) {
		pr_err("tkcoredrv: %s: invalid param\n", __func__);
		return -EINVAL;
	}

	if (copy_from_user(&ta, (void *) __tee_spta_inst_desc, sizeof(struct tee_spta_inst_desc))) {
		pr_err("tkcoredrv: %s: copy_from_user tee_spta_inst_desc failed\n", __func__);
		return -EINVAL;
	}

	if (ta.ta_size < 4) {
		return -EINVAL;
	}

	shm_in = tee_shm_alloc_from_rpc(tee, ta.ta_size, 0);
	if (IS_ERR_OR_NULL(shm_in)) {
		pr_err("tkcoredrv: %s: failed to alloc shm_in\n", __func__);
		return -ENOMEM;
	}

	shm_out = tee_shm_alloc_from_rpc(tee, ta.ta_size, 0);
	if (IS_ERR_OR_NULL(shm_out)) {
		pr_err("tkcoredrv: %s: failed to alloc shm_out\n", __func__);
		tee_shm_free_from_rpc(shm_in);
		return -ENOMEM;
	}

	if (copy_from_user(shm_in->resv.kaddr, (void *) ta.ta_binary, ta.ta_size)) {
		pr_err("tkcoredrv: %s: copy ta_binary failed\n", __func__);
		ret = -EINVAL;
		goto exit;
	}

	memset(&request, 0, sizeof(struct tee_rpc_invoke));

	request.cmd = TEE_RPC_INSTALL_TA;
	request.nbr_bf = 2;

	request.cmds[0].buffer = (void *) shm_in->resv.paddr;
	request.cmds[0].size = shm_in->size_req;

	request.cmds[1].buffer = (void *) shm_out->resv.paddr;
	request.cmds[1].size = shm_out->size_req;

	mutex_lock(&mutex_inst_ta);

	ret = tee_supp_cmd(ctx->tee, TEE_RPC_ICMD_INVOKE,
		&request, sizeof(struct tee_rpc_invoke));

	if (ret == 0)
		ret = request.res;

	if (ret) {
		pr_err("TA install command failed to start with %d\n", ret);
		goto exit;
	}

	down(&sem_inst_ta);

	mutex_unlock(&mutex_inst_ta);

	/*
		response_msg format：
		+----------------------------------+
		| TEE_Result | response_msg_len | response_msg_json | ta_bin_len | ta_bin |
		+--4bytes--------4bytes---------------------------------4bytes------------+
	*/

	memcpy(&ret, (void *) shm_out->resv.kaddr, 4);
	if (ret) {
		pr_err("tkcoredrv: install TA failed with 0x%x\n", ret);
		goto exit;
	}

	memcpy(&response_msg_len, (uint8_t *) shm_out->resv.kaddr + 4, 4);
	if (ta.ta_size - 4 < response_msg_len) {
		pr_err("tkcoredrv: unexpected response msg len: %u total_size: %u\n", ta.ta_size, response_msg_len);
		ret = -E2BIG;
		goto exit;
	}

	/* response_msg_len + sizeof(response_msg_len) + sizeof(TEE_Result */
	response_len = response_msg_len + 4 + 4;

	if ((ret = copy_to_user((void __user *) ta.ta_binary, (void *) shm_out->resv.kaddr, response_len))) {
		pr_err("tkcoredrv: copy response buffer failed with %d\n", ret);
		ret = ret < 0 ? ret : -EAGAIN;
		goto exit;
	}

	put_user(response_len, (uint32_t __user *) ta.response_len);

exit:
	tee_shm_free_from_rpc(shm_in);
	tee_shm_free_from_rpc(shm_out);

	return ret;
}

int tee_install_sp_ta_response(struct tee_context *ctx, void __user *u_arg)
{
	up(&sem_inst_ta);
	return 0;
}

int tee_delete_sp_ta(struct tee_context *ctx, void __user *uuid)
{
	int ret = 0;
	struct tee *tee = ctx->tee;
	struct tee_rpc_invoke request;
	struct tee_shm *shm_uuid;

	if (ctx == NULL || uuid == NULL) {
		pr_err("%s: invalid param\n", __func__);
		return -EINVAL;
	}

	shm_uuid = tee_shm_alloc_from_rpc(tee, sizeof(TEEC_UUID), 0);
	if (IS_ERR_OR_NULL(shm_uuid)) {
		pr_err("%s: failed to alloc shm uuid\n", __func__);
		return -ENOMEM;
	}

	if (copy_from_user(shm_uuid->resv.kaddr, uuid, sizeof(TEEC_UUID))) {
		pr_err("%s: TEEC_UUID copy_from_user failed\n", __func__);
		ret = -EINVAL;
		goto exit;
	}

	memset(&request, 0, sizeof(struct tee_rpc_invoke));

	request.cmd = TEE_RPC_DELETE_TA;
	request.nbr_bf = 1;
	request.cmds[0].buffer = (void *) shm_uuid->resv.paddr;
	request.cmds[0].size = shm_uuid->size_req;

	if ((ret = tee_supp_cmd(tee, TEE_RPC_ICMD_INVOKE, &request, sizeof(request)))) {
		pr_err("start delete_ta failed with %d\n", ret);
		goto exit;
	}

	if ((ret = request.res)) {
		pr_err("delete_ta failed with 0x%x\n", ret);
	}

exit:
	tee_shm_free_from_rpc(shm_uuid);
	return ret;
}

int tee_install_sys_ta(struct tee *tee, void __user *u_arg)
{
	int r;
	void *shm_kva;
	unsigned long left;

	TEEC_UUID uuid;
	struct tee_rpc_invoke inv;
	struct tee_shm *shm;

	struct tee_ta_inst_desc ta_inst_desc;

	if ((copy_from_user(&ta_inst_desc, u_arg, sizeof(struct tee_ta_inst_desc)))) {
		return -EFAULT;
	}

	if (copy_from_user(&uuid, ta_inst_desc.uuid, sizeof(TEEC_UUID))) {
		return -EFAULT;
	}

	if ((shm = tee_shm_alloc_from_rpc(tee, sizeof(TEEC_UUID) + sizeof(uint32_t) + ta_inst_desc.ta_buf_size, TEEC_MEM_NONSECURE)) == NULL) {
		pr_err("%s: tee_shm_alloc_ns(%uB) failed\n", __func__, ta_inst_desc.ta_buf_size);
		return -ENOMEM;
	}

	if ((shm_kva = vmap(shm->ns.pages, shm->ns.nr_pages, VM_MAP, PAGE_KERNEL)) == NULL) {
		pr_err("%s: failed to vmap %zu pages\n", __func__, shm->ns.nr_pages);
		r = -ENOMEM;
		goto exit;
	}

	memcpy(shm_kva, &uuid, sizeof(TEEC_UUID));
	memcpy((char *) shm_kva + sizeof(TEEC_UUID), &ta_inst_desc.ta_buf_size, sizeof(uint32_t));

	if ((left = copy_from_user(
		(char *) shm_kva + sizeof(TEEC_UUID) + sizeof(uint32_t), ta_inst_desc.ta_buf, ta_inst_desc.ta_buf_size))) {
		pr_err("%s: copy_from_user failed size %x return: %lu \n", __func__, ta_inst_desc.ta_buf_size, left);
		vunmap(shm_kva);
		r = -EFAULT;
		goto exit;
	}

	vunmap(shm_kva);

	memset(&inv, 0, sizeof(inv));

	inv.cmd = TEE_RPC_INSTALL_SYS_TA;
	inv.res = TEEC_ERROR_NOT_IMPLEMENTED;
	inv.nbr_bf = 1;

	inv.cmds[0].buffer = (void *) (unsigned long) shm->ns.token;
	inv.cmds[0].type = TEE_RPC_BUFFER | TEE_RPC_BUFFER_NONSECURE;
	inv.cmds[0].size = shm->size_req;

	if ((r = tee_supp_cmd(tee, TEE_RPC_ICMD_INVOKE, &inv, sizeof(inv)))) {
		pr_err("install_sys_ta failed with %d\n", r);
	} else {
		r = inv.res;
	}

exit:
	tee_shm_free_from_rpc(shm);

	return r;
}

int tee_ta_mgmt_init(void)
{
	mutex_init(&mutex_inst_ta);
	sema_init(&sem_inst_ta, 0);
	return 0;
}
