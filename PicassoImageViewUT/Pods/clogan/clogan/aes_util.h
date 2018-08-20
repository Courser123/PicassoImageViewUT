//
// Created by baitian0521 on 17/8/2.
//

#ifndef CLOGAN_AES_UTIL_H
#define CLOGAN_AES_UTIL_H


#include <string.h>

void aes_encrypt_clogan(unsigned char *in, unsigned char *out, int length, unsigned char *vi);

void aes_infalte_vi_clogan(unsigned char *aes_vi);

int aes_init_key_clogan(const char *aes_key, size_t len);

int aes_init_iv_clogan(const char *aes_iv_factor, size_t len);

char *aes_upload_key_clogan();

#endif //CLOGAN_AES_UTIL_H
