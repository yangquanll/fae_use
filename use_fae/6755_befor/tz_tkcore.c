/* Include header files */
#include "typedefs.h"
#include "tz_mem.h"
#include "uart.h"
#include "dram_buffer.h"
#include "platform.h"

#include <mmc_core.h>

#include "tz_tkcore.h"

#define MOD "[TZ_TKCORE]"

#define TEE_DEBUG
#ifdef TEE_DEBUG
#define DBG_MSG(str, ...) do {print(str, ##__VA_ARGS__);} while(0)
#else
#define DBG_MSG(str, ...) do {} while(0)
#endif

#if CFG_BOOT_ARGUMENT_BY_ATAG
extern unsigned int g_uart;
#elif CFG_BOOT_ARGUMENT && !CFG_BOOT_ARGUMENT_BY_ATAG
#define bootarg g_dram_buf->bootarg
#endif
#if CFG_TRUSTKERNEL_TEE_SDRPMB_SUPPORT

/*TODO check wp granularity / sector size */
int tz_mmc_set_write_prot(struct mmc_card *card, u32 addr);
int tz_mmc_clr_write_prot(struct mmc_card *card, u32 addr);

struct sdrpmb_info {
    int failed; int part_id;
    u32 sdrpmb_part_start;

    u32 sdrpmb_partaddr;
    u32 sdrpmb_partsize;
    u32 sdrpmb_starting_sector;
    u32 sdrpmb_nr_sectors;
} sdrpmb_info = { 0, -1, 0U, 0U, 0U, 0U, 0U };

static int set_tmpwp(u32 wp_sector, u32 nr_sector)
{
    int err = 0;
    u32 i;
    struct mmc_card *card;
    u8 usr_wp, value;
    u32 wpgrp_nr_sect = SDRPMB_REGION_ALIGNMENT / 512;

    if (!(card = mmc_get_card(0))) {
        DBG_MSG("Failed to get card\n");
        return -1;
    }

    if (!mmc_card_mmc(card)) {
        printf("%s: not mmc card!!!", __func__);
        return -1;
    }

    if (card->csd.mmca_vsn < CSD_SPEC_VER_4) {
        printf("%s: card csd not supported 0x%x\n", __func__, card->csd.mmca_vsn);
        return -1;
    }

    usr_wp = ((u8 *) card->raw_ext_csd)[EXT_CSD_USR_WP];
    value &= ~(EXT_CSD_USR_WP_EN_PERM_WP | EXT_CSD_USR_WP_EN_PERM_WP);

    if (value != usr_wp) {
        /* disable wp_perm/wp_pwr if enabled before */
        if ((err = mmc_switch(card->host, card, EXT_CSD_CMD_SET_NORMAL,
            EXT_CSD_USR_WP, value))) {
            printf("%s: mmc_switch err %d\n", MOD, err);
            goto out;
        }

        //check by read
        if ((err = mmc_read_ext_csd(card->host, card))) {
            printf("%s: read ext_csd err %d\n", MOD, err);
            goto out;
        }
    }

    for (i = 0; i < nr_sector; i += wpgrp_nr_sect) {
        if ((err = tz_mmc_set_write_prot(card, wp_sector + i))) {
            printf("%s tz_mmc_set_write_prot() sector=%u failed with %d\n",
                MOD, wp_sector, err);
            goto out;
        }
    }

    if (value != usr_wp) {
        //restore old value
        if ((err = mmc_switch(card->host, card, EXT_CSD_CMD_SET_NORMAL,
            EXT_CSD_USR_WP, usr_wp))) {
            printf("%s: restore usr_wp err: %d\n", MOD, err);
            goto out;
        }

        if ((err = mmc_read_ext_csd(card->host, card))) {
            printf("%s: read ext_csd err: %d\n", MOD, err);
            goto out;
        }
    }

out:
    return err;
}

static int clear_tmpwp(u32 wp_sector, u32 nr_sector)
{
    u32 i;
    int err = 0;
    struct mmc_card *card;

    u32 wpgrp_nr_sect = SDRPMB_REGION_ALIGNMENT / 512;

    if (!(card = mmc_get_card(0))) {
        DBG_MSG("Failed to get card\n");
        return -1;
    }

    if (!mmc_card_mmc(card)) {
        printf("%s: not mmc card!!!", __func__);
        return -1;
    }

    if (card->csd.mmca_vsn < CSD_SPEC_VER_4) {
        printf("%s: card csd not supported 0x%x\n", __func__, card->csd.mmca_vsn);
        return -1;
    }

    for (i = 0; i < nr_sector; i += wpgrp_nr_sect) {
        if ((err = tz_mmc_clr_write_prot(card, wp_sector + i))) {
            printf("%s tz_mmc_clr_write_prot() sect=%u failed with %d\n",
                MOD, wp_sector + i, err);
            goto out;
        }
    }
out:
    return err;
}

static u64 mblock_reserve_dryrun(mblock_info_t *mblock_info, u64 reserved_size)
{
    int i, max_rank, target = -1;
    u64 start, end, sz, max_addr = 0;
    u64 reserved_addr = 0, align, limit;
    mblock_t mblock;

    align = 1ULL << 20;
    /* address cannot go beyond 64bit */
    limit = 0x100000000ULL;
    /* always allocate from the larger rank */
    max_rank = mblock_info->mblock_num - 1;

    for (i = 0; i < mblock_info->mblock_num; i++) {
        start = mblock_info->mblock[i].start;
        sz = mblock_info->mblock[i].size;
        end = limit < (start + sz)? limit: (start + sz);
        reserved_addr = (end - reserved_size);
        reserved_addr &= ~(align - 1);
        if ((reserved_addr + reserved_size <= start + sz) &&
                (reserved_addr >= start) &&
                (mblock_info->mblock[i].rank <= max_rank) &&
                (start + sz > max_addr) &&
                (reserved_addr + reserved_size <= limit)) {
            max_addr = start + sz;
            target = i;
        }
    }

    if (target < 0) {
        printf("mblock_reserve error\n");
        return 0;
    }

    start = mblock_info->mblock[target].start;
    sz = mblock_info->mblock[target].size;
    end = limit < (start + sz)? limit: (start + sz);
    reserved_addr = (end - reserved_size);
    reserved_addr &= ~(align - 1);

    return reserved_addr;
}

/* note that memory is not really reserved */
static int reserve_tmpmem(mblock_info_t *mblock_info, u32 *addr, u32 size)
{
    u64 _addr = mblock_reserve_dryrun(mblock_info, size);
    if (_addr == 0ULL) {
        return -1;
    }

    /* we only reserve memory lower than 32-bit address, thus
       we can safely convert variable to u32 */
    *addr = (u32) _addr;
    return 0;
}

void sdrpmb_init_set_failed(void)
{
    sdrpmb_info.failed = 1;
    sdrpmb_info.sdrpmb_partaddr = SDRPMB_FAILURE_MAGIC;
    sdrpmb_info.sdrpmb_partsize = 0;
}

void tkcore_boot_param_prepare_sdrpmb_region(part_t *part)
{
    if (sdrpmb_info.failed || part == NULL) {
        return;
    }

    sdrpmb_info.part_id = part->part_id;

    u32 sect = part->start_sect + part->nr_sects;

    if (sect < SDRPMB_REGION_SIZE / 512) {
        printf("%s: unexpected MMC size: %u sectors\n", MOD, sect);
        goto err;
    }
    sect -= SDRPMB_REGION_SIZE / 512;
    /* sect % N must be smaller than sect */
    sect -= sect % (SDRPMB_REGION_ALIGNMENT / 512);

    if (sect < part->start_sect) {
        printf("%s: unexpected sdrpmb partition start: %u size: %u\n", MOD, part->start_sect, part->nr_sects);
        goto err;
    }

    sdrpmb_info.sdrpmb_part_start = part->start_sect;

    sdrpmb_info.sdrpmb_starting_sector = sect;
    sdrpmb_info.sdrpmb_nr_sectors = SDRPMB_REGION_SIZE / 512;

    if (set_tmpwp(sdrpmb_info.sdrpmb_starting_sector, sdrpmb_info.sdrpmb_nr_sectors)) {
        printf("%s set_tmpwp failed\n", MOD);
        goto err;
    }

    return;

err:
    sdrpmb_init_set_failed();
}

void tkcore_boot_param_prepare_sdrpmb_data(mblock_info_t *mblock, blkdev_t *bootdev)
{
    int ret = 0;
    u64 start_byte;

    if (sdrpmb_info.failed)
        return;

    /* check if sdrpmb region is not reserved */
    if (sdrpmb_info.part_id < 0)
        return;

    if (mblock == NULL || bootdev == NULL) {
        ret = -1;
        goto out;
    }

    sdrpmb_info.sdrpmb_partsize = SDRPMB_DATA_SIZE << 1;
    ret = reserve_tmpmem(mblock, &(sdrpmb_info.sdrpmb_partaddr), SDRPMB_DATA_SIZE << 1);
    if (ret) {
        printf("%s: reserve memory failed\n", MOD);
        goto out;
    }

    /* TODO use sector size instead of the hard coded 512 */
    start_byte = ((u64) sdrpmb_info.sdrpmb_starting_sector) * 512;

    if ((ret = blkdev_read(bootdev, start_byte, SDRPMB_DATA_SIZE,
        (u8 *) (sdrpmb_info.sdrpmb_partaddr), sdrpmb_info.part_id))) {
        printf("%s: read SDRPMB.0 failed", MOD);
        goto out;
    }

    if ((ret = blkdev_read(bootdev, start_byte + SDRPMB_REGION_ALIGNMENT,
        SDRPMB_DATA_SIZE, (u8 *) (sdrpmb_info.sdrpmb_partaddr + SDRPMB_DATA_SIZE),
        sdrpmb_info.part_id))) {
        printf("%s: read SDRPMB.1 failed", MOD);
        goto out;
    }

out:
    if (ret)
        sdrpmb_init_set_failed();
    return;
}

void tkcore_boot_sdrpmb_init_finish(u32 param_addr)
{
    int ret = 0;
    tee_arg_t_ptr teearg = (tee_arg_t_ptr) param_addr;

    if (teearg == NULL)
        return;

    if (!sdrpmb_info.failed && sdrpmb_info.part_id >= 0) {
        if (ret = clear_tmpwp(sdrpmb_info.sdrpmb_starting_sector,
            sdrpmb_info.sdrpmb_nr_sectors)) {
            printf("%s: clear_tmpwp failed", MOD);
            sdrpmb_init_set_failed();
        }
    }

    teearg->sdrpmb_partaddr = sdrpmb_info.sdrpmb_partaddr;
    teearg->sdrpmb_partsize = sdrpmb_info.sdrpmb_partsize;
    teearg->sdrpmb_starting_sector = sdrpmb_info.sdrpmb_starting_sector - sdrpmb_info.sdrpmb_part_start;
    teearg->sdrpmb_nr_sectors = sdrpmb_info.sdrpmb_nr_sectors;

    return;
}
#endif

void tkcore_boot_param_prepare(u32 param_addr, u32 tee_entry, 
    u64 sec_dram_size, u64 dram_base, u64 dram_size, int meta_uart)
{
    tee_arg_t_ptr teearg = (tee_arg_t_ptr) param_addr;

	if (teearg == NULL) {
		return;
	}

    /* Prepare TEE boot parameters */
    teearg->magic = TKCORE_BOOTCFG_MAGIC;
    teearg->length = sizeof(tee_arg_t);
	teearg->version = (u64) TEE_ARGUMENT_VERSION;
    teearg->dRamBase = dram_base;
    teearg->dRamSize = dram_size;
    teearg->secDRamBase = tee_entry;
    teearg->secDRamSize = sec_dram_size;
    teearg->secIRamBase = TEE_SECURE_ISRAM_ADDR;
    teearg->secIRamSize = TEE_SECURE_ISRAM_SIZE;

    /* GIC parameters */
    teearg->gic_distributor_base = GIC_BASE ;
    teearg->gic_cpuinterface_base = GIC_CPU;
    teearg->gic_version = GIC_VERSION ;
    
    /* SSI Reserve */
    teearg->total_number_spi = 256;
    teearg->ssiq_number = (32 + 248);

	teearg->flags = 0;

   if (meta_uart == 0) {
#if CFG_BOOT_ARGUMENT_BY_ATAG
       teearg->uart_base = g_uart;
       DBG_MSG("%s teearg : CFG_BOOT_ARGUMENT_BY_ATAG 0x%x\n", __func__, g_uart);
#elif CFG_BOOT_ARGUMENT && !CFG_BOOT_ARGUMENT_BY_ATAG
       teearg->uart_base = bootarg.log_port;
       DBG_MSG("%s teearg : CFG_BOOT_ARGUMENT 0x%x\n", __func__, bootarg.log_port);
#else
       teearg->uart_base = CFG_UART_LOG;
       DBG_MSG("%s teearg : log port by prj cfg 0x%x\n", __func__, CFG_UART_LOG);
#endif
   } else {
       teearg->uart_base = 0U;
   }

	DBG_MSG("%s teearg.magic: 0x%x\n", MOD, teearg->magic);
    DBG_MSG("%s teearg.length: 0x%x\n", MOD, teearg->length);
    DBG_MSG("%s teearg.version: 0x%x\n", MOD, teearg->version);
    DBG_MSG("%s teearg.dRamBase: 0x%x\n", MOD, teearg->dRamBase);
    DBG_MSG("%s teearg.dRamSize: 0x%x\n", MOD, teearg->dRamSize);
    DBG_MSG("%s teearg.secDRamBase: 0x%x\n", MOD, teearg->secDRamBase);
    DBG_MSG("%s teearg.secDRamSize: 0x%x\n", MOD, teearg->secDRamSize);
    DBG_MSG("%s teearg.secIRamBase: 0x%x\n", MOD, teearg->secIRamBase);
    DBG_MSG("%s teearg.secIRamSize: 0x%x\n", MOD, teearg->secIRamSize);
    DBG_MSG("%s teearg.gic_dist_base: 0x%x\n", MOD, teearg->gic_distributor_base);
    DBG_MSG("%s teearg.gic_cpu_base: 0x%x\n", MOD, teearg->gic_cpuinterface_base);
    DBG_MSG("%s teearg.gic_version: 0x%x\n", MOD, teearg->gic_version);
    DBG_MSG("%s teearg.uart_base: 0x%x\n", MOD, teearg->uart_base);
    DBG_MSG("%s teearg.total_number_spi: %d\n", MOD, teearg->total_number_spi);
    DBG_MSG("%s teearg.ssiq_number: %d\n", MOD, teearg->ssiq_number);
    DBG_MSG("%s teearg.flags: %x\n", MOD, teearg->flags);

    if (teearg->version >= TEE_ARGUMENT_VERSION_V1_0) {
        DBG_MSG("%s teearg.rpmb_key_programmed : %d\n",
            MOD, teearg->rpmb_key_programmed);
    }

    if (teearg->version >= TEE_ARGUMENT_VERSION_V1_1) {
        DBG_MSG("%s teearg.nw_bootargs: 0x%x\n", MOD, teearg->nw_bootargs);
        DBG_MSG("%s teearg.nw_bootargs_size: 0x%x\n", MOD, teearg->nw_bootargs_size);
    }

    if (teearg->version >= TEE_ARGUMENT_VERSION_V1_2) {
        DBG_MSG("%s teearg.sdrpmb_partaddr: 0x%x\n",
            MOD, teearg->sdrpmb_partaddr);
        DBG_MSG("%s teearg.sdrpmb_partsize: 0x%x\n",
            MOD, teearg->sdrpmb_partsize);
        DBG_MSG("%s teearg.sdrpmb_starting_sector: 0x%x\n",
            MOD, teearg->sdrpmb_starting_sector);
        DBG_MSG("%s teearg.sdrpmb_nr_sectors: 0x%x\n",
            MOD, teearg->sdrpmb_nr_sectors);
    }
}

void tkcore_boot_param_prepare_nwbootargs(u32 param_addr, u32 addr, u32 size)
{
    tee_arg_t_ptr teearg = (tee_arg_t_ptr) param_addr;

    if (teearg == NULL)
        return;

    teearg->nw_bootargs = addr;
    teearg->nw_bootargs_size = size;
}

void tkcore_boot_param_prepare_rpmbkey(u32 param_addr, u8 *rpmb_key, u32 rpmb_keylen)
{
    tee_arg_t_ptr teearg = (tee_arg_t_ptr) param_addr;

    if (teearg == NULL) {
        return ;
    }

    if (rpmb_keylen != RPMB_KEY_SIZE) {
        return ;
    }

    memcpy(teearg->rpmb_key, rpmb_key, RPMB_KEY_SIZE);
    teearg->rpmb_key_programmed = 1;
}
