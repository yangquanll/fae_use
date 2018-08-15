#ifndef IFAACLIENTBMT_TACLIENT_H
#define IFAACLIENTBMT_TACLIENT_H

#ifdef __cplusplus
extern "C" {
#endif

int alipay_tz_invoke_command(void *send_buf, uint32_t sbuf_len,
    void *rcv_buf, uint32_t *rbuf_len);

#ifdef __cplusplus
}
#endif

int invoke_command(void *send_buf, uint32_t sbuf_len,
    void *rcv_buf, uint32_t *rbuf_len);

#endif //IFAACLIENTBMT_TACLIENT_H
