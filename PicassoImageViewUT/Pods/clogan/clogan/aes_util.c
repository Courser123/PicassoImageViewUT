//
// Created by baitian0521 on 17/8/2.
//

#include "aes_util.h"
#include <stdio.h>
#include <stdlib.h>
#include "clogan_status.h"
#include "mbedtls/aes.h"
#include "mbedtls/md5.h"
#include "mbedtls/base64.h"
#include "mbedtls/rsa.h"
#include "console_util.h"


#define KEY_FACOTR_SALT_LOGAN "817b4bf903c16151"
#define IV_FACOTR_SALT_LOGAN  "a81a4aceb5eaec82"
#define MD5_SIZE_LOGAN 16

#define RSA_M_K_CLOGAN "137374487700076139638910447285701736211481331989948285181810825589425183415258184587856656459033169532882371152094864973244201931221748552719503316108538179773593057868281977791014545818942476770231825828941573352890753308624882208887241188296001754902203926436943744803329233029063451888189536419787671359079"
#define RSA_E_K_CLOGAN "65537"
#define KEY_LEN_CLOGAN 128

#define CLOGAN_AES_INITKEY_SUCCESS 0 //初始化Key成功

#define CLOGAN_AES_IV_SUCCESS 0 //获取iv成功

#define BASE64_LEN_CLOGAN 1024 //base64长度

static unsigned char KEY[16] = {0};
static char *UPLOAD_KEY = NULL;

static unsigned char VI[16] = {0};

#if defined(MBEDTLS_PKCS1_V15)

static int myrand(void *rng_state, unsigned char *output, size_t len) {
#if !defined(__OpenBSD__)
    size_t i;

    if (rng_state != NULL)
        rng_state = NULL;

    for (i = 0; i < len; ++i)
        output[i] = rand();
#else
    if( rng_state != NULL )
        rng_state = NULL;

    arc4random_buf( output, len );
#endif /* !OpenBSD */

    return (0);
}

#endif /* MBEDTLS_PKCS1_V15 */

void aes_encrypt_clogan(unsigned char *in, unsigned char *out, int length, unsigned char *vi) {
    mbedtls_aes_context context;
    mbedtls_aes_setkey_enc(&context, (unsigned char *) KEY, 128);
    mbedtls_aes_crypt_cbc(&context, MBEDTLS_AES_ENCRYPT, length, vi, in, out); //加密
}

void aes_infalte_vi_clogan(unsigned char *aes_vi) {
    memcpy(aes_vi, VI, 16);
}

/**
 *@brief 上传给服务器的key
 */
char *aes_upload_key_clogan() {
    return UPLOAD_KEY;
}

/**
 * @brief
 * 根据外界传递的key因子+固定因子，然后MD5得到aes的key值。对key值rsa公钥加密，然后base64得到要上传的值
 */
int aes_init_key_clogan(const char *aes_factor, size_t len) {
    char *item = KEY_FACOTR_SALT_LOGAN;
    int len1 = (int) strlen(item);
    int total = (int) (len1 + len);
    char content[total];
    memset(content, 0, total);
    memcpy(content, aes_factor, len);
    char *pointer = content + len;
    memcpy(pointer, item, len1);
    char md5_ptr[MD5_SIZE_LOGAN]; //MD5处理*
    memset(md5_ptr, 0, MD5_SIZE_LOGAN);
    mbedtls_md5((const unsigned char *) content, total, (unsigned char *) md5_ptr);

    printf_clogan("key md5 value : ");
    for (int i = 0; i < 16; i++) {
        printf_clogan("%02x", md5_ptr[i] & 0x0ff);
    }
    printf_clogan("\n");

    mbedtls_rsa_context rsa; //RSA处理（*）
    mbedtls_rsa_init(&rsa, MBEDTLS_RSA_PKCS_V15, 0);
    mbedtls_mpi_read_string(&rsa.N, 10, RSA_M_K_CLOGAN);
    mbedtls_mpi_read_string(&rsa.E, 10, RSA_E_K_CLOGAN);
    int flag = mbedtls_rsa_check_pubkey(&rsa);
    if (flag != 0) {
        return CLOGAN_INIT_INITPUBLICKEY_ERROR;
    }
    rsa.len = KEY_LEN_CLOGAN;
    unsigned char rsa_ciphertext[KEY_LEN_CLOGAN];
    flag = mbedtls_rsa_pkcs1_encrypt(&rsa, myrand, NULL, MBEDTLS_RSA_PUBLIC, MD5_SIZE_LOGAN,
                                     (const unsigned char *) md5_ptr,
                                     (unsigned char *) rsa_ciphertext);
    mbedtls_rsa_free(&rsa);
    if (flag != 0) {
        return CLOGAN_INIT_INITBLICKENCRYPT_ERROR;
    }

    char base64_array[BASE64_LEN_CLOGAN]; //base_64处理（*）
    size_t array_len = 0;
    flag = mbedtls_base64_encode((unsigned char *) base64_array, BASE64_LEN_CLOGAN, &array_len,
                                 (const unsigned char *) rsa_ciphertext, KEY_LEN_CLOGAN);
    if (flag != 0 || array_len <= 0) {
        return CLOGAN_INIT_INITBASE64_ERROR;
    }
    int base_len = (int) array_len + 1;
    char *base_str = (char *) malloc(base_len);
    if (base_str == NULL) {
        return CLOGAN_INIT_INITMALLOC_ERROR;
    }
    memset(base_str, 0, base_len);
    memcpy(base_str, base64_array, array_len);
    printf_clogan("base64 rsa key : %s\n", base_str);

    memcpy(KEY, md5_ptr, 16); //拷贝md5到制定Key数组重
    UPLOAD_KEY = base_str; //base_str在上报upload_key中
    return CLOGAN_AES_INITKEY_SUCCESS;
}

/**
 * @brief
 * 根据传递过来的因子+上规则生成md5的值
 */
int aes_init_iv_clogan(const char *aes_iv_factor, size_t len) {
    char *item = IV_FACOTR_SALT_LOGAN;
    int len1 = (int) strlen(item);
    int total = (int) (len1 + len);
    char content[total];
    memset(content, 0, total);
    memcpy(content, aes_iv_factor, len);
    char *pointer = content + len;
    memcpy(pointer, item, len1);
    char md5_ptr[MD5_SIZE_LOGAN]; //MD5处理
    memset(md5_ptr, 0, MD5_SIZE_LOGAN);
    mbedtls_md5((const unsigned char *) content, total, (unsigned char *) md5_ptr);
    printf_clogan("\niv value : ");
    for (int i = 0; i < 16; i++) {
        printf_clogan("%02x", md5_ptr[i] & 0x0ff);
    }
    printf_clogan("\n");
    memcpy(VI, md5_ptr, MD5_SIZE_LOGAN);
    return CLOGAN_AES_IV_SUCCESS;
}



