//
//  SY_SSWL_NetworkTool.m
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SY_SSWL_NetworkTool.h"

@interface SY_SSWL_NetworkTool ()
@property(nonatomic, strong) AFHTTPSessionManager *manager;
@property(nonatomic, strong) AFNetworkReachabilityManager *netManager;

@end

@implementation SY_SSWL_NetworkTool



- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


SYSingletonM(SY_SSWL_NetworkTool)

//*** 0、单例加载manager属性
-(void)getManagerBySingleton{
    _manager = [self singletonLoadManager];
    self.netManager = [self singletonLoadNetManager];
    //    [AVMPTool sharedAVMPTool]; //getSGAVMPWithParamStr
    
    /**
     * 用于退出游戏
     */
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(signOutGame:) name:SSWL_SignOutGame object:nil];
}

-(AFHTTPSessionManager *)singletonLoadManager{
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        //        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        //        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        /**
         * 设置请求头部
         
         @param NSString aliSDK请求头部的签名
         */
        //        [manager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
        
    });
    return manager;
}

- (AFNetworkReachabilityManager *)singletonLoadNetManager{
    static AFNetworkReachabilityManager *netManager = nil;
    static dispatch_once_t onecTokens;
    dispatch_once(&onecTokens, ^{
        netManager = [AFNetworkReachabilityManager manager];
    });
    return netManager;
}

- (void)logHTTPSStatusWihtTask:(NSURLSessionDataTask *)task{
    NSURLResponse *response = task.response;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;

    SYLog(@"HTTPS_Status -------- : %ld", (long)httpResponse.statusCode);
}

- (void)getNetWorkStateBlock:(void(^)(NSInteger netStatus))statusBlock{
    
    
    [self.netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: {
                SYLog(@"网络不可用");
                if (statusBlock) {
                    statusBlock(0);
                }
                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                SYLog(@"Wifi已开启");
                if (statusBlock) {
                    statusBlock(1);
                }
                
                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                SYLog(@"你现在使用的流量");
                if (statusBlock) {
                    statusBlock(2);
                }
                break;
            }
                
            case AFNetworkReachabilityStatusUnknown: {
                SYLog(@"你现在使用的未知网络");
                if (statusBlock) {
                    statusBlock(3);
                }
                
                break;
            }
                
            default:
                break;
        }
    }];
    [self.netManager startMonitoring];
    
}


/**
 * 阿里防火墙
 
 @param paramStr 请求链接
 @param param 参数
 */
- (void)getSGAVMPWithParamStr:(NSString *)paramStr param:(id)param{
    
    //    NSString *wToken = [[AVMPTool sharedAVMPTool] avmpSignWithParamStr:paramStr param:param];
    //    [_manager.requestSerializer setValue:wToken forHTTPHeaderField:@"wToken"];
    NSDictionary *requestHeaders = _manager.requestSerializer.HTTPRequestHeaders;
    
    //    NSString *user_Agent = [NSString string];
    if (![requestHeaders[@"User-Agent"] containsString:@"version"]) {
        NSString *user_Agent = [NSString stringWithFormat:@"%@/version(%@)", requestHeaders[@"User-Agent"], [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version];
        [_manager.requestSerializer setValue:user_Agent forHTTPHeaderField:@"User-Agent"];
        
    }
    
    SYLog(@"-------_manager.requestSerializer.HTTPRequestHeaders : %@   \n ----", _manager.requestSerializer.HTTPRequestHeaders);
    
}

//激活
- (void)getUserActivateCompletion:(void (^)(BOOL isActivate, id response))completion failure:(void (^ _Nullable)(NSError * _Nullable))failure{
    
    NSDictionary *params = [[SSWL_BasiceInfo sharedSSWL_BasiceInfo] getDeviceInfo];
    SYLog(@"激活-----params:%@------", params);
    NSString *paramStr =@"ct=index&ac=active";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", SSWL_URL_Head, paramStr];
    [self getSGAVMPWithParamStr:paramStr param:params];
    Weak_Self;
    [_manager POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"激活----------------originalDic-------- %@ ------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            NSDictionary *dic = originalDic[@"data"];
            SYLog(@"dic-------- %@",dic);
            if (completion) {
                completion(YES, originalDic);
            }
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
        if (failure) {
            failure(error);
        }

    }];
    
    
}


/**
 * 获取游戏基本信息
 */
- (void)getGameInfoCompletion:(void(^)(BOOL isSuccess, id response)) completion failure:(void(^)(NSError * error))failure{
    NSDictionary *paramterDict = @{
                            @"token"     :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
                            };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=sys&ac=getGameInfo";
    [self getResponseWithUrl:paramStr parameters:params medthod:@"游戏基本信息" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess){
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion( NO, responesObj);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}



- (void)getRegexpCompletion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    NSDictionary *paramterDict = @{
                            @"language"     :   @"oc",
                            };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=sys&ac=getRegexp";
    [self getResponseWithUrl:paramStr parameters:params medthod:@"获取正则表达式" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess){
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion( NO, responesObj);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
       
    }];
}

//客服....
- (void)getCustomerServiceCompletion:(void(^)(BOOL isSuccess, id response)) completion failure:(void (^ _Nullable)(NSError * _Nullable))failure{
    NSDictionary *paramterDict = @{
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          };
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=sys&ac=getOnlineKefuUrl";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", SSWL_URL_Head, paramStr];
    //    [self getSGAVMPWithParamStr:paramStr param:params];
    
    Weak_Self;
    [_manager POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"激活----------------originalDic-------- %@ ------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            NSDictionary *dic = originalDic[@"data"];
            SYLog(@"客服链接------- dic-------- %@",dic);
            if (completion) {
                completion(YES, originalDic);
            }
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
    }];
    
}


//游客
- (void)registTouristCompletion:(void (^)(BOOL, id))completion  failure:(void(^_Nullable)(NSError *_Nullable error))failure{
    Weak_Self;
    NSDictionary *paramterDict = @{
                          @"device_id"   : [[SSWL_BasiceInfo sharedSSWL_BasiceInfo] getUUID],
                          @"app_id"      : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"app_channel"  : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].app_channel,
                          @"system_name" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model,
                          @"system_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].system_Version,
                          @"platform"    : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"idfa"        : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfa,
                          @"idfv"        : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfv,
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    SYLog(@"游客------params:%@-----", params);
    
    NSString *paramStr = @"ct=index&ac=guestLogin";
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SSWL_URL_Head, paramStr];
    [self getSGAVMPWithParamStr:paramStr param:params];
    
    
    [_manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"游客---------------------originalDic-------- %@------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            NSDictionary *dic = originalDic[@"data"];
            SYLog(@"dic-------- %@",dic);
            //            [weakSelf saveWithUsername:originalDic[@"data"][@"username"] andWithPassword:originalDic[@"data"][@"password"]];
            
            NSString *username = [NSString stringWithFormat:@"%@", originalDic[@"data"][@"username"]];
            
            id touristPass = originalDic[@"data"][@"password"];
            if (touristPass) {
                NSString *password = [NSString stringWithFormat:@"%@", touristPass];
                if ([KeyChainWrapper load:SSWL_UserName_Fast] == nil || ![[KeyChainWrapper load:SSWL_UserName_Fast] isEqualToString:username]) {
                    
                    if ([KeyChainWrapper load:SSWL_Password_Fast] == nil) {
                        [KeyChainWrapper save:SSWL_UserName_Fast data:username];
                        [KeyChainWrapper save:SSWL_Password_Fast data:password];
                    }
                    
                }
            }
            
            //            password = @"123456789";
           
           
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].fastUserName = username;
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser = username;
            if (![SSWL_PublicTool getTouristState]) {
                [SSWL_PublicTool useToTouristLogin:YES];
                
            }
            //            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isTouristLogin = [SSWL_PublicTool getTouristState];
            NSString *touristStr = @"ct=index&ac=guestLogin";
            NSString *touristUrl = [NSString stringWithFormat:@"%@%@", SSWL_URL_Head, touristStr];
            //            NSString *wToken = [[AVMPTool sharedAVMPTool] avmpSignWithParamStr:touristStr param:params];
            //            [_manager.requestSerializer setValue:wToken forHTTPHeaderField:@"wToken"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken = dic[@"token"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameCode = dic[@"code"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl = dic[@"h5_game_url"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString = dic[@"o"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].userId = dic[@"user_id"];
            
            [SSWL_PushInfo sharedSSWL_PushInfo].isLoginStatus = YES;
            
            [weakSelf getUserBasicInfoCompletion:^(BOOL isSuccess, id respones) {
                if (isSuccess) {
                    SYLog(@"%@", respones);
                    NSDictionary *dict = respones[@"data"];
                    NSString *phoneNumber = dict[@"phone"];
                    
                    if (phoneNumber.length > 1) {
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = YES;
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber = phoneNumber;
                    }else{
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = NO;
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber = @"";
                    }
                    SYLog(@"[SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = %d", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone);
                    
                   
                    
                    if (completion) {
                        completion(YES, originalDic);
                    }
                }else{
                    SYLog(@"%@", respones);
                    if (completion) {
                        completion(NO, originalDic);
                    }
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
                [weakSelf logHTTPSStatusWihtTask:task];
                SYLog(@"-------------------- Error : %@", error);
            }];
            
            
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
        
        
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
        if (failure){
            failure(error);
        }
    }];
    
}






//注册
- (void)registWithUserName:(NSString *)userName password:(NSString *)password regType:(RegistType)registType code:(NSString *)code completion:(void (^)(BOOL, id _Nullable))completion  failure:(void(^_Nullable)(NSError *_Nullable error))failure{
    NSString *reg_type = [NSString string];
    if (registType == RegistTypeName) {
        reg_type = @"0";
        if (code == nil && code.length < 1) {
            code = @"";
        }
    }else{
        reg_type = @"1";
        if (password == nil || password.length < 1) {
            password = @"";
        }
    }
    Weak_Self;
    NSDictionary *paramterDict = @{
                          @"device_id"   : [[SSWL_BasiceInfo sharedSSWL_BasiceInfo] getUUID],
                          @"app_id"      : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"app_channel"  : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].app_channel,
                          @"system_name" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model,
                          @"system_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].system_Version,
                          @"platform"    : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"username"    : userName,
                          @"password"    : password,
                          @"reg_type"    : reg_type,
                          @"code"        : code,
                          @"idfa"        : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfa,
                          @"idfv"        : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfv,
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          
                          };
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    SYLog(@"注册------params:%@-----", params);
    NSString *paramStr = @"ct=index&ac=reg";
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SSWL_URL_Head, paramStr];
    [self getSGAVMPWithParamStr:paramStr param:params];
    
    [_manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"注册---------------------originalDic-------- %@------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            NSDictionary *dic = originalDic[@"data"];
            SYLog(@"dic-------- %@",dic);
//            [weakSelf saveWithUsername:userName password:password];
            [UserSafetyTool saveWithUsername:userName password:password token:nil];
            if (completion) {
                completion(YES, originalDic);
            }
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure){
            failure(error);
        }
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
    }];
    
    
}

//登录
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(void (^)(BOOL, id _Nullable))completion  failure:(void(^_Nullable)(NSError *_Nullable error))failure{
    Weak_Self;
    
    NSDictionary *paramterDict = @{
                          @"device_id"      :   [[SSWL_BasiceInfo sharedSSWL_BasiceInfo] getUUID],
                          @"app_id"         :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"app_channel"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].app_channel,
                          @"system_name"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model,
                          @"system_version" :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].system_Version,
                          @"platform"       :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,//,
                          @"time"           :   [SSWL_PublicTool getTimeStamps],
                          @"idfa"           :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfa,
                          @"idfv"           :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfv,
                          @"sdk_version"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"username"       :   userName,
                          @"password"       :   password,
                          };
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    NSString *paramStr = @"ct=index&ac=login";
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SSWL_URL_Head, paramStr];
    SYLog(@"登录------params:%@-----", params);
    [self getSGAVMPWithParamStr:paramStr param:params];
    
    //    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].wtoken = wToken;
    
    [_manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"登录---------------------originalDic-------- %@------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            NSDictionary *dic = originalDic[@"data"];
            //            SYLog(@"dic-------- %@",dic);

            
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].fastUserName = userName;
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser = userName;
            //            [weakSelf saveWithUsername:userName password:password];
            
            
            //         NSString *str = dic[@"h5_game_url"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken = dic[@"token"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameCode =dic[@"code"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl = dic[@"h5_game_url"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString = dic[@"o"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].userId = dic[@"user_id"];

            [SSWL_PushInfo sharedSSWL_PushInfo].isLoginStatus = YES;
            
            [UserSafetyTool saveWithUsername:userName password:password token:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken];

            [SSWL_PublicTool firstOpenApplication:YES];
            
            
            
            [weakSelf getUserBasicInfoCompletion:^(BOOL isSuccess, id respones) {
                if (isSuccess) {
                    SYLog(@"%@", respones);
                    NSDictionary *dict = respones[@"data"];
                    NSString *phoneNumber = dict[@"phone"];
                    if (phoneNumber.length > 1) {
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = YES;
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber = phoneNumber;
                    }else{
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = NO;
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber = @"";
                    }
                    SYLog(@"[SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = %d", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone);
                    
                    
                    if (completion) {
                        completion(YES, originalDic);
                    }
                    
                }else{
                    SYLog(@"%@", respones);
                    if (completion) {
                        completion(NO, originalDic);
                    }
                    
                }
            } failure:^(NSError *error) {
            
            SYLog(@"-------------------- Error : %@", error);
                if (failure) {
                    failure(error);
                }
            }];
            
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure){
            failure(error);
        }
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
    }];
    
}

- (void)checkIfTheUserExistsWithUserName:(NSString *)userName userType:(NSInteger)userType completion:(void (^ _Nullable)(BOOL, id _Nullable))completion failure:(void (^ _Nullable)(NSError * _Nullable))failure{
    NSString *user_type = [NSString stringWithFormat:@"%ld", (long)userType];
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"platform"    : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,
                          @"device_id"   : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].uuid,
                          @"username"    : userName,
                          @"user_type"   : user_type,
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    SYLog(@"账号是否存在------params:%@-----", params);
    NSString *paramStr = @"ct=index&ac=checkUsername";
    [self getResponseWithUrl:paramStr parameters:params medthod:@"账号是否存在" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (([SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString.length > 0) || ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameCode.length > 0)){
                //  [weakSelf createFloatWindow];
                
            }
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
}


- (void)noticeBeforTheLoginCompletion:(void(^)(BOOL isSuccess, id respones))completion failure:(void(^)(NSError * error))failure{
    
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"device_id"   : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].uuid,
                          @"token"       : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
                          @"type"        : @"sdk",
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    SYLog(@"是否有登录后公告------params:%@-----", params);
    NSString *paramStr = @"ct=notice&ac=getHotNewGameNoticeList";
    
    [self getResponseWithUrl:paramStr parameters:params medthod:@"登录后公告" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (([SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString.length > 0) || ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameCode.length > 0)){
                //  [weakSelf createFloatWindow];
                
            }
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
}



- (void)verifyDynamicPasswordWithKey:(NSString *)key completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"app_id"      : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"device_id"   : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].uuid,
                          @"token"       : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
                          @"key"         : key,
                          };
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    SYLog(@"验证动态口令------params:%@-----", params);
    NSString *paramStr = @"ct=index&ac=verifyDynamicPassword";
    
    [self getResponseWithUrl:paramStr parameters:params medthod:@"验证动态口令" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].isAppStatus) {
                [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] createFloatWindow];
            }
            if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl.length > 0) {
                
            }
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


//检查是否有登录公告
- (void)checkLoginNoticeCompletion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"app_id"      : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"device_id"   : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].uuid,
                          };
    
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    NSString *paramStr = @"ct=notice&ac=checkLoginNotice";
    //    [self getSGAVMPWithParamStr:paramStr param:params];
    SYLog(@"是否有登录公告------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"是否有登录公告" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}




- (void)shareTheGameGiftInfoCompletion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"device_id"   : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].uuid,
                          @"token"       : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
                          };
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=share&ac=getShareInfo";
    
    [self getResponseWithUrl:paramStr parameters:params medthod:@"请求分享内容" completion:^(BOOL isSuccess, id responesObj) {
        if (completion) {
            completion(isSuccess, responesObj);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}


- (void)checkExpiredForToken:(NSString *)token userName:(NSString *)userName completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    Weak_Self;
    NSDictionary *paramterDict = @{
                          @"device_id"      :   [[SSWL_BasiceInfo sharedSSWL_BasiceInfo] getUUID],
                          @"app_id"         :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"app_channel"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].app_channel,
                          @"system_name"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model,
                          @"system_version" :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].system_Version,
                          @"platform"       :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,//,
                          @"time"           :   [SSWL_PublicTool getTimeStamps],
                          @"idfa"           :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfa,
                          @"idfv"           :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfv,
                          @"sdk_version"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"username"       :   userName,
                          @"token"          :   token,
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=index&ac=checkToken";
    
    SYLog(@"token是否过期 ------params:%@-----", params);
    [self getSGAVMPWithParamStr:paramStr param:params];
    
    //    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].wtoken = wToken;
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SSWL_URL_Head, paramStr];
    
    [_manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"登录---------------------originalDic-------- %@------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            NSDictionary *dic = originalDic[@"data"];
            //            SYLog(@"dic-------- %@",dic);
            
           
            
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].fastUserName = dic[@"username"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser = dic[@"username"];
            //            [weakSelf saveWithUsername:userName password:password];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken = dic[@"token"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameCode = dic[@"code"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl = dic[@"h5_game_url"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString = dic[@"o"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].userId = dic[@"user_id"];
            
            [SSWL_PushInfo sharedSSWL_PushInfo].isLoginStatus = YES;
            
            if ([SSWL_PublicTool isValidateTel:dic[@"username"]]) {
                NSMutableDictionary *passD = [KeyChainWrapper load:SSWLPasswordKey];
                NSString *password = [passD valueForKey:dic[@"username"]];
                [UserSafetyTool saveWithUsername:dic[@"username"] password:password token:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken];
            }
            [SSWL_PublicTool firstOpenApplication:YES];
            
            
            
            [weakSelf getUserBasicInfoCompletion:^(BOOL isSuccess, id respones) {
                if (isSuccess) {
                    SYLog(@"%@", respones);
                    NSDictionary *dict = respones[@"data"];
                    NSString *phoneNumber = dict[@"phone"];
                    if (phoneNumber.length > 1) {
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = YES;
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber = phoneNumber;
                    }else{
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = NO;
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber = @"";
                    }
                    SYLog(@"[SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = %d", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone);
                    if (completion) {
                        completion(YES, originalDic);
                    }
                }else{
                    SYLog(@"%@", respones);
                    if (completion) {
                        completion(NO, originalDic);
                    }
                }
            } failure:^(NSError *error) {
                
            }];
            
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
    }];
}

- (void)phoneLoginWithPhoneNumber:(NSString *)phoneNumber code:(NSString *)code completion:(void (^)(BOOL, id _Nullable, NSString *_Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    Weak_Self;
    
    NSDictionary *paramterDict = @{
                          @"device_id"      :   [[SSWL_BasiceInfo sharedSSWL_BasiceInfo] getUUID],
                          @"app_id"         :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"app_channel"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].app_channel,
                          @"system_name"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model,
                          @"system_version" :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].system_Version,
                          @"platform"       :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,//,
                          @"time"           :   [SSWL_PublicTool getTimeStamps],
                          @"idfa"           :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfa,
                          @"idfv"           :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfv,
                          @"sdk_version"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"phone"          :   phoneNumber,
                          @"code"           :   code,
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=index&ac=phoneLogin";
    
    SYLog(@"token 失效, 使用验证码登录 ------params:%@-----", params);
    [self getSGAVMPWithParamStr:paramStr param:params];
    
    //    [SSWL_BasiceInfo sharedSSWL_BasiceInfo].wtoken = wToken;
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SSWL_URL_Head, paramStr];
    
    [_manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"登录---------------------originalDic-------- %@------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            NSDictionary *dic = originalDic[@"data"];
            //            SYLog(@"dic-------- %@",dic);
            
            
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].fastUserName = dic[@"username"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser = dic[@"username"];
            //            [weakSelf saveWithUsername:userName password:password];
            
            
            //         NSString *str = dic[@"h5_game_url"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken = dic[@"token"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].gameCode = dic[@"code"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl = dic[@"h5_game_url"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString = dic[@"o"];
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].userId = dic[@"user_id"];
            
            [SSWL_PushInfo sharedSSWL_PushInfo].isLoginStatus = YES;
            
            if ([SSWL_PublicTool isValidateTel:dic[@"username"]]) {
                NSMutableDictionary *passD = [KeyChainWrapper load:SSWLPasswordKey];
                NSString *password = [passD valueForKey:dic[@"username"]];
                [UserSafetyTool saveWithUsername:dic[@"username"] password:password token:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken];
            }
            [SSWL_PublicTool firstOpenApplication:YES];
            
           
            
            [weakSelf getUserBasicInfoCompletion:^(BOOL isSuccess, id respones) {
                if (isSuccess) {
                    SYLog(@"%@", respones);
                    NSDictionary *dict = respones[@"data"];
                    NSString *phoneNumber = dict[@"phone"];
                    if (phoneNumber.length > 1) {
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = YES;
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber = phoneNumber;
                    }else{
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = NO;
                        [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bindPhoneNumber = @"";
                    }
                    SYLog(@"[SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone = %d", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindPhone);
                    if (completion) {
                        completion(YES, originalDic, @"");
                    }
                }else{
                    SYLog(@"%@", respones);
                    if (completion) {
                        completion(NO, originalDic, @"");
                    }
                }
            } failure:^(NSError *error) {
                
            }];
            
        }else{
            if (completion) {
                completion(NO, originalDic, @"");
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(NO, error, @"网络异常");
        }
        
    }];
    
}

- (void)checkGameNoticeCompletion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"app_id"      : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"device_id"   : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].uuid,
                          @"token"       : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=notice&ac=checkUserGameNotice";
    
    SYLog(@"是否有未读游戏公告 ------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"是否有未读游戏公告" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}





//绑定手机号码
- (void)bindMobileWithToken:(NSString *)tokenStr code:(NSString *)code phoneNumber:(NSString *)phoneNum completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"phone"       : phoneNum,//phoneNum
                          @"token"       : tokenStr,
                          @"code"        : code,
                          };
    
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=user&ac=bindPhone";
    
    SYLog(@"绑定手机号码------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"绑定手机号码" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
}



- (void)getUserBasicInfoCompletion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"token"       : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=user&ac=getUserInfo";
    
    SYLog(@"获取用户基本信息-------params:%@", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"获取用户基本信息" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            
            NSDictionary *dict = responesObj[@"data"];
            NSString *identityCardString = dict[@"idcard"];
            if (identityCardString.length < 7) {
                [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindingIdCard = NO;
            }else{
                [SSWL_BasiceInfo sharedSSWL_BasiceInfo].isBindingIdCard = YES;
            }
            
            
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}


//通过老密码修改新密码
- (void)modifyPasswordWithToken:(NSString *)tokenStr oldPassword:(NSString *)oldPassword password:(NSString *)password repasswrod:(NSString *)repassword completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    NSDictionary *paramterDict = @{
                          @"token"              :           tokenStr,
                          @"old_password"       :           oldPassword,
                          @"password"           :           password,
                          @"repassword"         :           repassword,
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          
                          };
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    SYLog(@"通过老密码修改新密码-------params:%@", params);
    
    NSString *paramStr = @"ct=user&ac=editPwdByOldPassword";
    
    [self getResponseWithUrl:paramStr parameters:params medthod:@"老密码修改新密码" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}




//绑定手机验证码
- (void)bindPhoneSmsWithPhoneNumber:(NSString *)phoneNum completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"phone"       : phoneNum,//phoneNum
                          @"type"        : @"bind_phone",
                          };
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=index&ac=sms";
    
    SYLog(@"绑定手机验证码------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"绑定手机验证码" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}


//注册手机账号验证码
- (void)loginForPhoneSmsWithPhoneNumber:(NSString *)phoneNum completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"phone"       : phoneNum,//phoneNum
                          @"type"        : @"phone_login",
                          };
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=index&ac=sms";
    
    SYLog(@"绑定手机验证码------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"绑定手机验证码" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

// 短信验证码
- (void)getFindPasswordSmsWithPhoneNumber:(NSString *)phoneNum completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"phone"       : phoneNum,//phoneNum
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=index&ac=sendEditPwdSms";
    
    SYLog(@"短信验证码------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"短信验证" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

//检测短信验证码和手机号码...手机找回密码
- (void)checkSmsWithPhone:(NSString *)phoneNum code:(NSString *)code completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"phone"       : phoneNum,//phoneNum
                          @"code"        : code,
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=index&ac=checkSms";
    
    SYLog(@"手机找回密码------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"验证短信和手机号码_手机找回密码" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//通过手机修改密码
- (void)changePassword:(NSString *)password phoneNum:(NSString *)phoneNum code:(NSString *)code completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"phone"       : phoneNum,//phoneNum
                          @"code"        : code,
                          @"password"    : password,
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=index&ac=editPwd";
    
    SYLog(@"通过手机修改密码------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"手机修改密码" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
}

/*
 验证身份证
 */
- (void)verifyIdcardWithName:(NSString *)name idCard:(NSString *)idCard completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    NSDictionary *paramterDict = @{
                          @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"        : [SSWL_PublicTool getTimeStamps],
                          @"token"       : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
                          @"device_id"   : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].uuid,
                          @"name"        : name,
                          @"idcard"      : idCard,
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=user&ac=verifyIdcard";
    
    SYLog(@"验证身份证------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"验证身份证" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

- (void)clearDeviceIdWithAppId:(NSString *)appId completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    NSDictionary *paramterDict = @{
                            @"app_id"      : appId,
                            @"device_id"   : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].uuid,
                            };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    
    NSString *paramStr = @"ct=sys&ac=clearDevice";
    SYLog(@"------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"清理deviceID" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
    
}

- (void)postServerUserDeviceId:(NSString *)userDeviceId
              completion:(void(^ _Nullable)(BOOL isSuccess, id _Nullable respones))completion
                 failure:(void(^ _Nullable)(NSError *_Nullable error))failure{
    if (![userDeviceId isKindOfClass:[NSString class]] || userDeviceId.length < 1) {
        SYLog(@"error : userDeviceId 非字符串或为空------- %@", [NSString stringWithFormat:@"%@", userDeviceId]);
        return;
    }
    NSDictionary *paramterDict = @{
                                   @"device_id"      : userDeviceId,
                                   @"token"   : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdkToken,
                                   };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];
    
    
    
    NSString *paramStr = @"ct=push&ac=setUserDeviceId";
    SYLog(@"------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"阿里云推送deviceID" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}


//获取基本数据 -> 主要用于切换中英文界面.
- (void)getInfoWithAppId:(NSString *)appId completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    //944A19D5514A4AC28BAA412133FBBCF9
    
    NSDictionary *params = @{
                             @"app_id"      : appId,
                             @"device_id"   : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].uuid,
                             @"sdk_version" : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                             @"platform"   :  [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,
                             };
    
    
    NSString *paramStr = @"ct=sys&ac=getInfo";
    
    SYLog(@"------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"基础数据" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
    
}


//用户创建角色
- (void)userCreateRoleWithRoleId:(NSString *)roleId userId:(NSString *)userId htmlSign:(NSString *)htmlSign time:(NSString *)time completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    if (htmlSign.length < 1) {
        htmlSign = @"";
    }
    NSDictionary *paramterDict = @{
                            @"app_id"          : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                            @"app_channel"     : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].app_channel,
                            @"platform"        : @"ios",
                            @"time"            : time,
                            @"role_id"         : roleId,
                            @"game_sign"       : htmlSign,
                            @"user_id"         : userId,
                            };
    
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=index&ac=createRole";
    SYLog(@"用户创建角色------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"创建角色" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
    
    
}

// 游戏角色在线5分钟
- (void)onlineFor5MinutesWithUserId:(NSString *)userId roleId:(NSString *)roleId time:(NSString *)time htmlSign:(NSString *)htmlSign completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    if (htmlSign.length < 1) {
        htmlSign = @"";
    }
    NSDictionary *paramterDict = @{
                            @"app_id"          : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                            @"app_channel"     : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].app_channel,
                            @"platform"        : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,
                            @"time"            : time,
                            @"role_id"         : roleId,
                            @"game_sign"       : htmlSign,
                            @"user_id"         : userId,
                            };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    
    NSString *paramStr = @"ct=index&ac=roleOnline";
    SYLog(@"游戏角色在线5分钟------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"在线5分钟" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
}

//升级调用接口
- (void)levelUpWithUserId:(NSString *)userId roleId:(NSString *)roleId level:(NSString *)level time:(NSString *)time htmlSign:(NSString *)htmlSign completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    if (htmlSign.length < 1) {
        htmlSign = @"";
    }
    NSDictionary *paramterDict = @{
                            @"app_id"          : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                            @"platform"        : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,
                            @"time"            : time,
                            @"role_id"         : roleId,
                            @"user_id"         : userId,
                            @"level"           : level,
                            @"game_sign"       : htmlSign,
                            };
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];
    
    NSString *paramStr = @"ct=index&ac=roleLevel";
    SYLog(@"升级调用接口------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"升级接口" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}


- (void)userServerLoginWithUserId:(NSString *)userId serverId:(NSString *)serverId loginTime:(NSString *)loginTime time:(NSString *)time gameSign:(NSString *)gameSign completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    if (gameSign.length < 1) {
        gameSign = @"";
    }
    if (time.length < 1) {
        time = @"";
    }
    
    NSDictionary *paramterDict = @{
                            @"app_id"               : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                            @"platform"             : [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,
                            @"time"                 : time,
                            @"server_id"            : serverId,
                            @"login_time"           : loginTime,
                            @"user_id"              : userId,
                            @"game_sign"            : gameSign,
                            };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];
    NSString *paramStr = @"ct=index&ac=serverLogin";
    SYLog(@"用户登入区服调用接口------params:%@-----", params);
    [self getResponseWithUrl:paramStr parameters:params medthod:@"用户登入区服" completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    }failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}




- (void)checkWebSYSignWithParams:(NSDictionary *)params completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    Weak_Self;
    
    NSString *paramStr = @"ct=index&ac=checkWebPaySign";
    NSString *urlString = [NSString stringWithFormat:@"%@", SSWL_SYUrl_CheckWeb];
    SYLog(@"验证游戏参数------params:%@-----", params);
    [_manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"------------------originalDic-------- %@------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            //            NSDictionary *dic = originalDic[@"data"];
            //            SYLog(@"dic-------- %@",dic);
            if (completion) {
                completion(YES, originalDic);
            }
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
    }];
}


/*
 * 临时多一层封装
 */
- (void)getDataForResponseWithUrl:(NSString *)paramStr parameters:(id)params medthod:(NSString *)medthod completion:(void(^)(BOOL isSuccess, id responesObj))completion failure:(void(^)(NSError * error))failure{
    
    Weak_Self;
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SSWL_URL_Head, paramStr];
    //    [self getSGAVMPWithParamStr:paramStr param:params];
    
    [_manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"%@-------------originalDic-------- %@------------message:%@", medthod,originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            //            NSDictionary *dic = originalDic[@"data"];
            //            SYLog(@"dic-------- %@",dic);
            //            _manager.
            if (completion) {
                completion(YES, originalDic);
            }
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
    }];
    
    
    
}


- (void)testInfoToAnyParamCompletion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    Weak_Self;
    NSDictionary *param = @{
                            @"username" :  @"king5566",
                            @"password" :  @"qweqwe123",
                            };
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@", SSWL_COM_Test];
    NSString *sign = [SSWL_PublicTool makeSignStringWithParams:param key:SSWL_BBS_KEY];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:param];
    [params setObject:sign forKey:@"sdk_code"];
    SYLog(@"登录------params:%@-----", params);
    [_manager POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"%@------------------originalDic-------- %@------------message:%@", @"测试社区模块",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"success"] intValue] == 1) {
            if (completion) {
                completion(YES, originalDic);
            }
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
    }];
    
    
}


//公共请求方法..
- (void)getResponseWithUrl:(NSString *)paramStr parameters:(id)params medthod:(NSString *)medthod completion:(void(^)(BOOL isSuccess, id responesObj))completion failure:(void(^)(NSError * error))failure{
    //    Weak_Self;
    [self getDataForResponseWithUrl:paramStr parameters:params medthod:medthod completion:^(BOOL isSuccess, id responesObj) {
        if (isSuccess) {
            if (completion) {
                completion(YES, responesObj);
            }
        }else{
            if (completion) {
                completion(NO, responesObj);
                
            }
            
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}



- (void)checkSongyorkWithSongyorkInfo:(SongyorkInfo *)songyorkInfo completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    Weak_Self;
    NSDictionary *paramterDict = @{
                          @"user_id"         :   songyorkInfo.uid,
                          @"game_role_level" :   songyorkInfo.roleLevel,
                          @"platform"        :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].platform,
                          @"app_id"          :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"sdk_version"     :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"            :   [SSWL_PublicTool getTimeStamps],
                          };
   
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];
    SYLog(@"------params:%@-----", params);
    NSString *urlString = [NSString stringWithFormat:@"%@", SSWL_SYUrl_Check];
    
    
    [_manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"--------------originalDic-------- %@------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            //            NSDictionary *dic = originalDic[@"data"];
            //            SYLog(@"dic-------- %@",dic);
            if (completion) {
                completion(YES, originalDic);
            }
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
    }];
   
}

/**
 * 请求支付
 */

- (void)requestSongyorkWithInfo:(SongyorkInfo *)songyorkInfo completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    
    NSDictionary *paramterDict = @{
                          @"user_id"        :   songyorkInfo.uid,
                          @"money"          :   songyorkInfo.money,
                          @"money_type"     :   songyorkInfo.moneyType,
                          @"server"         :   songyorkInfo.serverId,
                          @"cp_trade_sn"    :   songyorkInfo.YYY,
                          @"goods_id"       :   songyorkInfo.proId,
                          @"goods_name"     :   songyorkInfo.productName,
                          @"game_role_id"   :   songyorkInfo.roleId,
                          @"game_role_name" :   songyorkInfo.roleName,
                          @"pay_type"       :   @"apple",
                          @"sub_pay_type"   :   @"apple",
                          @"app_channel"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].app_channel,
                          @"device_id"      :   [[SSWL_BasiceInfo sharedSSWL_BasiceInfo] getUUID],
                          @"app_id"         :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sswl_AppId,
                          @"idfv"           :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].idfv,
                          @"sdk_version"    :   [SSWL_BasiceInfo sharedSSWL_BasiceInfo].sdk_Version,
                          @"time"           :   [SSWL_PublicTool getTimeStamps],
                          };
    
    NSDictionary *params = [SSWL_PublicTool signKeyMustStringFromDictionary:paramterDict];

    SYLog(@"------params:%@-----", params);
    //    NSString *paramStr =@"ct=index&ac=active";
    //    NSString *urlStr = [NSString stringWithFormat:@"%@%@", SSWL_URL_Head, paramStr];
    //    [self getSGAVMPWithParamStr:@"" param:params];
    
    Weak_Self;
    [_manager POST:SSWL_SYUrl_Head parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"-------originalDic-------- %@------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"state"] intValue] == 1) {
            //            NSDictionary *dic = originalDic[@"data"];
            //            SYLog(@"dic-------- %@",dic);
            if (completion) {
                completion(YES, originalDic);
            }
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
        if (failure) {
            failure(error);
        }
        
        
    }];
   
    
}

/**
 * 检查是否有weifukuan的回调
 */
- (void)checkSongyorkToServerWithReceiptInfo:(id)param completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    NSDictionary *dic = param;
    
    //    NSString *deletSign = [NSString stringWithFormat:@"%@", dic[@"sign"]];
    //    if (deletSign.length > 1) {
    //        [dic removeObjectForKey:@"sign"];
    //    }
    SYLog(@"检查支付--------------------Param:%@", dic);
    
    SYLog(@"------params:%@-----", param);
    
    Weak_Self;
    [_manager POST:SSWL_SYUrl_CallBack parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"检查支付--------------originalDic-------- %@------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"status"] intValue] == 1) {
            NSDictionary *dic = originalDic[@"data"];
            SYLog(@"dic-------- %@",dic);
            if (completion) {
                completion(YES, originalDic);
            }
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
        if (failure) {
            failure(error);
        }
        
    }];
}


/**
 * 支付完成的回调
 */

- (void)callBackToSongyorkServerWithReceiptInfo:(id)param completion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    
    
    SYLog(@"---------------------- param : %@", param);
    //    [self getSGAVMPWithParamStr:@"" param:param];
    Weak_Self;
    [_manager POST:SSWL_SYUrl_CallBack parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf logHTTPSStatusWihtTask:task];
        NSDictionary *originalDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        SYLog(@"支付完成-----------------originalDic-------- %@------------message:%@",originalDic, originalDic[@"msg"]);
        if ([originalDic[@"status"] intValue] == 1) {
            
            NSDictionary *dic = originalDic[@"data"];
            SYLog(@"支付完成---success----dic-------- %@",dic);
            if (completion) {
                completion(YES, originalDic);
            }
        }else{
            if (completion) {
                completion(NO, originalDic);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf logHTTPSStatusWihtTask:task];
        SYLog(@"-------------------- Error : %@", error);
        if (failure) {
            failure(error);
        }
        
    }];
    
}


/**
 * 接收通知的响应事件方法
 */
- (void)signOutGame:(NSNotification *)notification{
    BOOL isOut = [[notification.userInfo valueForKey:notification.object] boolValue];
    
    if (isOut) {
        if ([SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool].htmlWindow) {
            [SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool].htmlWindow.hidden = YES;
            [SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool].htmlWindow = nil;
            [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] destroyFloatWindow];

        }
    }
}



/*
 
 #pragma mark ----------------------------------------------保存账号信息
 //*** 登录或者注册成功后保存账号、密码，最多保存5个
 -(void)saveWithUsername:(NSString *)username password:(NSString *)password{
 if ([KeyChainWrapper load:SSWLUsernameKey] == nil) {
 NSMutableArray *userNameArray = [NSMutableArray array];
 [userNameArray insertObject:username atIndex:0];
 [KeyChainWrapper save:SSWLUsernameKey data:userNameArray];
 }else{
 NSMutableArray *userNameArr = [KeyChainWrapper load:SSWLUsernameKey];
 if ([userNameArr containsObject:username]) {
 //            NSMutableDictionary *haveUserDict = [KeyChainWrapper load:SSWLPasswordKey];
 //            [haveUserDict removeObjectForKey:username];
 //            [KeyChainWrapper save:SSWLPasswordKey data:haveUserDict];
 
 [userNameArr removeObject:username];
 [userNameArr insertObject:username atIndex:0];
 [KeyChainWrapper save:SSWLUsernameKey data:userNameArr];
 
 }else{
 if (userNameArr.count == 5) {
 NSMutableDictionary *userDict = [KeyChainWrapper load:SSWLPasswordKey];
 [userDict removeObjectForKey:userNameArr[4]];
 [KeyChainWrapper save:SSWLPasswordKey data:userDict];
 
 [userNameArr removeObjectAtIndex:4];
 [userNameArr insertObject:username atIndex:0];
 [KeyChainWrapper save:SSWLUsernameKey data:userNameArr];
 }else{
 [userNameArr insertObject:username atIndex:0];
 [KeyChainWrapper save:SSWLUsernameKey data:userNameArr];
 }
 }
 }
 //*** 、字典保存账号、密码，最多5个
 if ([KeyChainWrapper load:SSWLPasswordKey] == nil) {
 NSMutableDictionary *dict = [NSMutableDictionary dictionary];
 [dict setObject:password forKey:username];
 [KeyChainWrapper save:SSWLPasswordKey data:dict];
 }else{
 NSMutableDictionary *userDict = [KeyChainWrapper load:SSWLPasswordKey];
 if ([userDict objectForKey:username]) {
 if (![password isEqualToString:[userDict objectForKey:username]]) {
 [userDict setObject:password forKey:username];
 [KeyChainWrapper save:SSWLPasswordKey data:userDict];
 }
 
 }else{
 [userDict setObject:password forKey:username];
 [KeyChainWrapper save:SSWLPasswordKey data:userDict];
 }
 }
 }
 */



@end
