//
// Created by baitian0521 on 17/8/1.
//

#include "zlib_util.h"
#include "aes_util.h"
#include "console_util.h"

int init_zlib_clogan(cLogan_Model *model){
    int ret = 1;
    if(model->zlib_type == LOGAN_ZLIB_INIT){ //如果是init的状态则不需要init
        return Z_OK;
    }
    z_stream  * temp_zlib = NULL;
    if(!model->isMalloc_zlib){
        temp_zlib = malloc(sizeof(z_stream));
    } else {
        temp_zlib = model->strm;
    }

    if(NULL != temp_zlib){
        model->isMalloc_zlib = 1; //表示已经 malloc 一个zlib
        memset(temp_zlib , 0 , sizeof(z_stream));
        model->strm = temp_zlib;
        temp_zlib->zalloc = Z_NULL;
        temp_zlib->zfree = Z_NULL;
        temp_zlib->opaque = Z_NULL;
        ret = deflateInit2(temp_zlib, Z_BEST_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
        if (ret == Z_OK){
            model->isGzip = 1;
            model->zlib_type = LOGAN_ZLIB_INIT;
        } else {
            model->isGzip = 0;
            model->zlib_type = LOGAN_ZLIB_FAIL;
        }
    } else {
        model->isMalloc_zlib = 0 ;
        model->isGzip = 0;
        model->zlib_type = LOGAN_ZLIB_FAIL;

    }

    return ret;
}

void clogan_zlib(cLogan_Model *model, char *data, int data_len, int type){
    int isGzip = model->isGzip;
    unsigned int have;
    unsigned char out[LOGAN_CHUNK];
    int ret;
    z_stream  *strm = model->strm;
    if(isGzip){
        strm->avail_in = (uInt)data_len;
        strm->next_in = (unsigned char *)data;
        do {
            strm->avail_out = LOGAN_CHUNK;
            strm->next_out =(unsigned char *) out;
            ret = deflate(strm, type);
            if(Z_STREAM_ERROR == ret){
                deflateEnd(model->strm);

                model->isGzip = 0 ;
                model->zlib_type = LOGAN_ZLIB_END;
            } else {
                have = LOGAN_CHUNK - strm->avail_out;
//                printf_clogan("clogan_zlib > hava value : %d\n", have);
//                fwrite(out , sizeof(char) , have , model->file);
                int total_len = model->remain_data_len + have;
                unsigned char *temp = NULL;
                int handler_len = (total_len / 16) * 16;
                int remain_len = total_len % 16;
                if(handler_len){
                    int copy_data_len = handler_len - model->remain_data_len ;
                    char gzip_data[handler_len];
                    temp = (unsigned char *)gzip_data;
                    if(model->remain_data_len){
                        memcpy(temp , model->remain_data , model->remain_data_len);
                        temp += model->remain_data_len;
                    }
                    memcpy(temp , out ,copy_data_len); //填充剩余数据和压缩数据

                    aes_encrypt_clogan((unsigned char *)gzip_data, model->last_point, handler_len, (unsigned char *)model->aes_vi); //把加密数据写入缓存
//                    fwrite(gzip_data , sizeof(char) , handler_len , model->file);
                    model->total_len += handler_len;
                    model->content_len += handler_len;
                    model->last_point += handler_len;
                }
                if(remain_len){
                    if(handler_len){
                        int copy_data_len = handler_len - model->remain_data_len ;
                        temp = (unsigned char *)out;
                        temp += copy_data_len;
                        memcpy(model->remain_data , temp ,remain_len); //填充剩余数据和压缩数据
                    }
                    else{
                        temp = (unsigned char *)model->remain_data;
                        temp += model->remain_data_len;
                        memcpy(temp , out , have);
                    }
                }
                model->remain_data_len = remain_len;
            }
        } while (strm->avail_out == 0);
    } else {

    }

}

void clogan_zlib_end_compress(cLogan_Model *model){
    clogan_zlib(model, NULL, 0, Z_FINISH);
    (void) deflateEnd(model->strm);
    int val = 16 - model->remain_data_len;
    char data[16];
    memset(data , val , 16);
    if(model->remain_data_len){
        memcpy(data , model->remain_data , model->remain_data_len);
    }
//    fwrite(model->remain_data , sizeof(char) , model->remain_data_len , model->file);
    aes_encrypt_clogan((unsigned char *)data, model->last_point, 16, (unsigned char *)model->aes_vi); //把加密数据写入缓存
    model->last_point += 16;
    *(model->last_point) = LOGAN_WRITE_PROTOCOL_TAIL;
    model->last_point++;
    model->remain_data_len = 0;
    model->total_len += 17;
    model->content_len += 16; //为了兼容之前协议content_len,只包含内容,不包含结尾符
    model->zlib_type = LOGAN_ZLIB_END;
    model->isGzip = 0;
}



void clogan_zlib_compress(cLogan_Model *model, char *data, int data_len){
    if(model->zlib_type == LOGAN_ZLIB_ING || model->zlib_type == LOGAN_ZLIB_INIT){
        model->zlib_type = LOGAN_ZLIB_ING;
        clogan_zlib(model, data, data_len, Z_SYNC_FLUSH);
    } else {
        init_zlib_clogan(model);
    }
}

void clogan_zlib_delete_stream(cLogan_Model *model){
    (void) deflateEnd(model->strm);
    model->zlib_type = LOGAN_ZLIB_END;
    model->isGzip = 0;

}
