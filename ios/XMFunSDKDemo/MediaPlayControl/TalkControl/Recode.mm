//
//  Recode.m
//  界面1
//
//  Created by hzjf on 14-1-7.
//  Copyright (c) 2014年 hzjf. All rights reserved.
//

#import "Recode.h"
#import "FunSDK/netsdk.h"
#import "FunSDK/FunSDK.h"
//#import "AppDelegate.h"

unsigned char _l2A[2048] = {
	0xd5, 0xd4, 0xd7, 0xd6, 0xd1, 0xd0, 0xd3, 0xd2,
	0xdd, 0xdc, 0xdf, 0xde, 0xd9, 0xd8, 0xdb, 0xda,
	0xc5, 0xc4, 0xc7, 0xc6, 0xc1, 0xc0, 0xc3, 0xc2,
	0xcd, 0xcc, 0xcf, 0xce, 0xc9, 0xc8, 0xcb, 0xca,
	0xf5, 0xf5, 0xf4, 0xf4, 0xf7, 0xf7, 0xf6, 0xf6,
	0xf1, 0xf1, 0xf0, 0xf0, 0xf3, 0xf3, 0xf2, 0xf2,
	0xfd, 0xfd, 0xfc, 0xfc, 0xff, 0xff, 0xfe, 0xfe,
	0xf9, 0xf9, 0xf8, 0xf8, 0xfb, 0xfb, 0xfa, 0xfa,
	0xe5, 0xe5, 0xe5, 0xe5, 0xe4, 0xe4, 0xe4, 0xe4,
	0xe7, 0xe7, 0xe7, 0xe7, 0xe6, 0xe6, 0xe6, 0xe6,
	0xe1, 0xe1, 0xe1, 0xe1, 0xe0, 0xe0, 0xe0, 0xe0,
	0xe3, 0xe3, 0xe3, 0xe3, 0xe2, 0xe2, 0xe2, 0xe2,
	0xed, 0xed, 0xed, 0xed, 0xec, 0xec, 0xec, 0xec,
	0xef, 0xef, 0xef, 0xef, 0xee, 0xee, 0xee, 0xee,
	0xe9, 0xe9, 0xe9, 0xe9, 0xe8, 0xe8, 0xe8, 0xe8,
	0xeb, 0xeb, 0xeb, 0xeb, 0xea, 0xea, 0xea, 0xea,
	0x95, 0x95, 0x95, 0x95, 0x95, 0x95, 0x95, 0x95,
	0x94, 0x94, 0x94, 0x94, 0x94, 0x94, 0x94, 0x94,
	0x97, 0x97, 0x97, 0x97, 0x97, 0x97, 0x97, 0x97,
	0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96,
	0x91, 0x91, 0x91, 0x91, 0x91, 0x91, 0x91, 0x91,
	0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90,
	0x93, 0x93, 0x93, 0x93, 0x93, 0x93, 0x93, 0x93,
	0x92, 0x92, 0x92, 0x92, 0x92, 0x92, 0x92, 0x92,
	0x9d, 0x9d, 0x9d, 0x9d, 0x9d, 0x9d, 0x9d, 0x9d,
	0x9c, 0x9c, 0x9c, 0x9c, 0x9c, 0x9c, 0x9c, 0x9c,
	0x9f, 0x9f, 0x9f, 0x9f, 0x9f, 0x9f, 0x9f, 0x9f,
	0x9e, 0x9e, 0x9e, 0x9e, 0x9e, 0x9e, 0x9e, 0x9e,
	0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99,
	0x98, 0x98, 0x98, 0x98, 0x98, 0x98, 0x98, 0x98,
	0x9b, 0x9b, 0x9b, 0x9b, 0x9b, 0x9b, 0x9b, 0x9b,
	0x9a, 0x9a, 0x9a, 0x9a, 0x9a, 0x9a, 0x9a, 0x9a,
	0x85, 0x85, 0x85, 0x85, 0x85, 0x85, 0x85, 0x85,
	0x85, 0x85, 0x85, 0x85, 0x85, 0x85, 0x85, 0x85,
	0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84,
	0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84,
	0x87, 0x87, 0x87, 0x87, 0x87, 0x87, 0x87, 0x87,
	0x87, 0x87, 0x87, 0x87, 0x87, 0x87, 0x87, 0x87,
	0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86,
	0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86, 0x86,
	0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81,
	0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81,
	0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
	0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
	0x82, 0x82, 0x82, 0x82, 0x82, 0x82, 0x82, 0x82,
	0x82, 0x82, 0x82, 0x82, 0x82, 0x82, 0x82, 0x82,
	0x8d, 0x8d, 0x8d, 0x8d, 0x8d, 0x8d, 0x8d, 0x8d,
	0x8d, 0x8d, 0x8d, 0x8d, 0x8d, 0x8d, 0x8d, 0x8d,
	0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c,
	0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c,
	0x8f, 0x8f, 0x8f, 0x8f, 0x8f, 0x8f, 0x8f, 0x8f,
	0x8f, 0x8f, 0x8f, 0x8f, 0x8f, 0x8f, 0x8f, 0x8f,
	0x8e, 0x8e, 0x8e, 0x8e, 0x8e, 0x8e, 0x8e, 0x8e,
	0x8e, 0x8e, 0x8e, 0x8e, 0x8e, 0x8e, 0x8e, 0x8e,
	0x89, 0x89, 0x89, 0x89, 0x89, 0x89, 0x89, 0x89,
	0x89, 0x89, 0x89, 0x89, 0x89, 0x89, 0x89, 0x89,
	0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88,
	0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88,
	0x8b, 0x8b, 0x8b, 0x8b, 0x8b, 0x8b, 0x8b, 0x8b,
	0x8b, 0x8b, 0x8b, 0x8b, 0x8b, 0x8b, 0x8b, 0x8b,
	0x8a, 0x8a, 0x8a, 0x8a, 0x8a, 0x8a, 0x8a, 0x8a,
	0x8a, 0x8a, 0x8a, 0x8a, 0x8a, 0x8a, 0x8a, 0x8a,
	0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5,
	0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5,
	0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5,
	0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5, 0xb5,
	0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4,
	0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4,
	0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4,
	0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4,
	0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7,
	0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7,
	0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7,
	0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7, 0xb7,
	0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6,
	0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6,
	0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6,
	0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6, 0xb6,
	0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1,
	0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1,
	0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1,
	0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1,
	0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0,
	0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0,
	0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0,
	0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0,
	0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3,
	0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3,
	0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3,
	0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3, 0xb3,
	0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2,
	0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2,
	0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2,
	0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2, 0xb2,
	0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd,
	0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd,
	0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd,
	0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd, 0xbd,
	0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc,
	0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc,
	0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc,
	0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc, 0xbc,
	0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf,
	0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf,
	0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf,
	0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf,
	0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe,
	0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe,
	0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe,
	0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe, 0xbe,
	0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9,
	0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9,
	0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9,
	0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9, 0xb9,
	0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8,
	0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8,
	0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8,
	0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8, 0xb8,
	0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb,
	0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb,
	0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb,
	0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb, 0xbb,
	0xba, 0xba, 0xba, 0xba, 0xba, 0xba, 0xba, 0xba,
	0xba, 0xba, 0xba, 0xba, 0xba, 0xba, 0xba, 0xba,
	0xba, 0xba, 0xba, 0xba, 0xba, 0xba, 0xba, 0xba,
	0xba, 0xba, 0xba, 0xba, 0xba, 0xba, 0xba, 0xba,
	0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5,
	0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5,
	0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5,
	0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5,
	0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5,
	0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5,
	0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5,
	0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5, 0xa5,
	0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4,
	0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4,
	0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4,
	0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4,
	0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4,
	0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4,
	0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4,
	0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4, 0xa4,
	0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7,
	0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7,
	0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7,
	0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7,
	0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7,
	0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7,
	0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7,
	0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7, 0xa7,
	0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6,
	0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6,
	0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6,
	0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6,
	0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6,
	0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6,
	0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6,
	0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6, 0xa6,
	0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1,
	0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1,
	0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1,
	0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1,
	0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1,
	0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1,
	0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1,
	0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1, 0xa1,
	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0,
	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0,
	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0,
	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0,
	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0,
	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0,
	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0,
	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0,
	0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3,
	0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3,
	0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3,
	0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3,
	0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3,
	0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3,
	0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3,
	0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3, 0xa3,
	0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2,
	0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2,
	0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2,
	0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2,
	0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2,
	0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2,
	0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2,
	0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2, 0xa2,
	0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad,
	0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad,
	0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad,
	0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad,
	0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad,
	0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad,
	0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad,
	0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad, 0xad,
	0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac,
	0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac,
	0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac,
	0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac,
	0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac,
	0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac,
	0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac,
	0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac, 0xac,
	0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf,
	0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf,
	0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf,
	0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf,
	0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf,
	0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf,
	0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf,
	0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf, 0xaf,
	0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae,
	0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae,
	0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae,
	0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae,
	0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae,
	0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae,
	0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae,
	0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae, 0xae,
	0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9,
	0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9,
	0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9,
	0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9,
	0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9,
	0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9,
	0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9,
	0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9, 0xa9,
	0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8,
	0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8,
	0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8,
	0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8,
	0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8,
	0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8,
	0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8,
	0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8, 0xa8,
	0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab,
	0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab,
	0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab,
	0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab,
	0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab,
	0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab,
	0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab,
	0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab, 0xab,
	0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
	0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
	0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
	0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
	0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
	0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
	0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
	0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
};

/*
 ==G711£¨±‡¬Î
 */
int Encode_g711a( char *src, char *dest, int srclen, int *dstlen )
{
	int	i,tmp;
	signed short src_data;
	unsigned char	mask;
	unsigned short *ps=(unsigned short*)src;

	*dstlen=0;
	tmp = srclen/2;
    
	for(i=0; i<tmp; i++)
	{
		src_data = ps[i];
		mask = (src_data < 0) ? 0x7f : 0xff;
		if (src_data < 0)
			src_data = -src_data;
		src_data >>= 4;
		dest[i] = _l2A[src_data] & mask;
	}
	*dstlen = srclen/2;
	return 1;
}
@implementation Recode
{
    //NSString *deviceMac;
    
}
@synthesize aqc;



static void AQInputCallback(void         *inUserData,
               AudioQueueRef    inAudioQueue,
               AudioQueueBufferRef  inBuffer,
               const AudioTimeStamp *inStartTime,
               UInt32      inNumPackets,
                            const AudioStreamPacketDescription * inPacketDesc)
{
    Recode *engine = (__bridge Recode *)inUserData;
    
    if (inNumPackets >0) {
        [engine processAudioBuffer:inBuffer withQueue:inAudioQueue];
    }
    
    if (engine.aqc.run) {
        AudioQueueEnqueueBuffer(engine.aqc.queue, inBuffer, 0, NULL);
    }
}   

- (id)init{
    self = [super init];
    
    if (self){
        
        //声音初始化
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        NSError *error;
        BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
        if(!success)
        {
            NSLog(@"error doing outputaudioportoverride - %@", [error localizedDescription]);
        }
        
        //设置录音采样率
        aqc.mDataFormate.mSampleRate = kSamplingRate;
        //设置录音格式
        aqc.mDataFormate.mFormatID = kAudioFormatLinearPCM;
        aqc.mDataFormate.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger |kLinearPCMFormatFlagIsPacked;
        aqc.mDataFormate.mFramesPerPacket = 1;
        aqc.mDataFormate.mChannelsPerFrame = kNumberChannels;
        
        aqc.mDataFormate.mBitsPerChannel = kBitesPerChannels;
        
        aqc.mDataFormate.mBytesPerPacket = kBytesPerFrame;
        aqc.mDataFormate.mBytesPerFrame = kBytesPerFrame;
        
        aqc.frameSize = kFrameSize;
        AudioQueueNewInput(&aqc.mDataFormate, AQInputCallback, (__bridge void*)(self), NULL, NULL,0, &aqc.queue);
        
        for (int i=0;i<kNumberBuffers;i++)
        {
            AudioQueueAllocateBuffer(aqc.queue, (int)aqc.frameSize, &aqc.mBuffers[i]);
            AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
        }
        
        aqc.recPtr = 0;
        aqc.run = 1;
        self.sendData = TRUE;
        
        int status = AudioQueueStart(aqc.queue, NULL);
        
        //[[AVAudioSession sharedInstance] setDelegate:self];
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,audioRouteChangeListenerCallback, (__bridge void *)(self));//调用block函数
    }
    
    return self;
}

- (void)startRecode:(NSString *)devMac {
    //设置成耳机模式
   // [Recode setHeadsetMode];
    self.deviceMac = devMac;
    int status =AudioQueueStart(aqc.queue, NULL);
}

- (void)stopRecode
{
    //设置成扬声器模式
    //[Recode setSpeakMode];
    int status = AudioQueueStop(aqc.queue, true);
}


- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue
{
    
    long size = buffer->mAudioDataByteSize / aqc.mDataFormate.mBytesPerPacket;
    char * srcData = (char *) buffer->mAudioData;
    int dataSize = buffer->mAudioDataByteSize;
  
    if (self.delegate) {
        [self.delegate audioRecordData:(char *)srcData size:dataSize];
    }
    //因为音质优化和变声功能，数据发送改为到TalkControl工具类中
    //FUN_DevSendTalkData([self.deviceMac UTF8String], (char *)srcData, dataSize);
}
+ (void)setHeadsetMode {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}
+ (void)setSpeakMode {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

void audioRouteChangeListenerCallback (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize,const void *inPropertyValue ) {
    
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    {
        CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
        
        CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason) );
        
        SInt32 routeChangeReason;
        
        CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
        
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            //插上耳机
            [Recode setSpeakMode];
            
        } else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
            //拔掉耳机
            [Recode setHeadsetMode];

        }
    }
}

@end
