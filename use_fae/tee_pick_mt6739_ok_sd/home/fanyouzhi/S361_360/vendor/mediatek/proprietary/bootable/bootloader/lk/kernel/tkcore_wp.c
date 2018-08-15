#include <platform/partition.h>
#include <debug.h>

#define CMD_SDRPMB_ACTIVE_STATE 0xBF000200
#define CMD_SDRPMB_REGION_INFO  0xBF000201

uint32_t tkcore_smc(uint32_t smc_id, uint32_t *a, uint32_t *b)
{
    uint32_t r, p, q;
    __asm__ __volatile__(
        "mov r0, %[smcid]\n"
        "smc #0x0\n"
        "mov %[arg0], r0\n"
        "mov %[arg1], r1\n"
        "mov %[arg2], r2\n":
            [arg0]"=r"(r),
            [arg1]"=r"(p),
            [arg2]"=r"(q):

            [smcid]"r"(smc_id):
            "cc", "r0", "r1" ,"r2", "r3"
    );

    *a = p;
    *b = q;
    return r;
}

void tkcore_wp_init(void)
{
    int r;
    uint32_t active_id, status, start_sect, nr_sects;

    part_t *part = mt_part_get_partition("sdrpmb");

    if (part == NULL)
        return;

    if ((tkcore_smc(CMD_SDRPMB_ACTIVE_STATE, &active_id, &status))) {
        dprintf(CRITICAL, "Get SDRPMB active state failed\n");
        return;
    }

    if ((tkcore_smc(CMD_SDRPMB_REGION_INFO, &start_sect, &nr_sects))) {
        dprintf(CRITICAL, "Get SDRPMB region info failed\n");
        return;
    }

    dprintf(CRITICAL, "active_id: %u status: %u\n", active_id, status);
    dprintf(CRITICAL, "start_sect: %u nr_sectors: %u\n", start_sect, nr_sects);

    if (status == 2) {
        /* partition needs to be protected */
        dprintf(ALWAYS, "SDRPMB region cannot be initialized. WP the whole region\n");
        if ((r = mmc_set_write_protect(0, EMMC_PART_USER,
                start_sect + part->start_sect,
                nr_sects, WP_POWER_ON))) {
            dprintf(CRITICAL, "SDRPMB: WP the whole region failed with %d\n", r);
        }
    } else {
        if (active_id == 0) {
            dprintf(CRITICAL, "SDRPMB[1]: SET WP (%lu, %u)\n",
                start_sect + part->start_sect + nr_sects / 2,
                nr_sects / 2);

            if ((r = mmc_set_write_protect(0, EMMC_PART_USER,
                start_sect + part->start_sect + nr_sects / 2,
                nr_sects / 2, WP_POWER_ON))) {
                dprintf(CRITICAL, "SDRPMB[1]: SET WP failed with %d\n", r);
                goto out;
            }
        } else if (active_id == 1) {
           dprintf(CRITICAL, "SDRPMB[0]: SET WP (%lu, %u)\n",
                start_sect + part->start_sect, nr_sects / 2);

            if ((r = mmc_set_write_protect(0, EMMC_PART_USER,
                start_sect + part->start_sect,
                nr_sects / 2, WP_POWER_ON))) {
                dprintf(CRITICAL, "SDRPMB[0]: SET WP failed with %d\n", r);
                goto out;
            }
        }
    }
out:
    return;
}
