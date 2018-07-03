//
//  SSWL_PublickTool.m
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_PublicTool.h"

@implementation SSWL_PublicTool


//*** 1、获取bundle文件
+ (NSBundle *_Nullable)getResourceBundle
{
    NSURL *bundleUrl = [[NSBundle mainBundle] URLForResource:@"AYSDKBundle" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:bundleUrl];
}


//*** 2、获取bunle文件里面的图片
+ (UIImage *)getImageFromBundle:(NSBundle *_Nullable)bundle withName:(NSString *_Nullable)name withType:(NSString *_Nullable)type{
    NSString *imagePath = [bundle pathForResource:name ofType:type];
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:imagePath]];
    return image;
}

+ (NSString *)getSourceFromBundle:(NSBundle *_Nullable)bundle withName:(NSString *_Nullable)name{
    NSString *str = [bundle pathForResource:name ofType:@"json"];
    NSString *sourceString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:str] encoding:NSASCIIStringEncoding];
    if (str.length < 1) {
        str = @"";
    }
    if (sourceString.length < 1) {
        sourceString = @"";
    }
    return sourceString;
}
//*** 3、将字符串转换成md5
+ (NSString *_Nullable)toMD5:(NSString *_Nullable)targetString{
    if (targetString){
        const char* data = [targetString UTF8String];
        unsigned int len= (unsigned int)strlen(data);
        unsigned char result[16];
        CC_MD5(data,len,result);
        NSString* md5_string = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                                result[0],result[1],result[2],result[3],result[4],result[5],result[6],
                                result[7],result[8],result[9],result[10],
                                result[11],result[12],result[13],result[14],result[15]];
        return [md5_string lowercaseString];
    }
    return nil;
}

/**
 请求签名
 */

+ (NSString *_Nullable)makeSignStringWithParams:(NSDictionary *_Nullable)params{
    NSString *string1 =[[NSString alloc]init];
    NSArray *sortedArray = [params.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString *sortedKey in sortedArray) {
        
        NSString *keyValue = [NSString stringWithFormat:@"%@=%@&",sortedKey,params[sortedKey]];
        NSString *string2 =[NSString stringWithFormat:@"%@%@",string1,keyValue];
        string1 = string2;
    }
    NSString *sortedString = [NSString string];
    NSString *lastString = [NSString string];
    if (string1.length > 0) {
        sortedString = [NSString stringWithFormat:@"%@%@",SSWL_API_KEY,string1];
        lastString = [sortedString substringWithRange:NSMakeRange(0, sortedString.length - 1)];
        
    }else{
        sortedString = [NSString stringWithFormat:@"%@",SSWL_API_KEY];
        lastString = [sortedString substringWithRange:NSMakeRange(0, sortedString.length)];
        
    }
    NSString *sign = [SSWL_PublicTool toMD5:lastString];
    return sign;
}


/**
 BBS签名
 
 @param params 需要签名的字符串
 @param key 加密的key
 @return 签名
 */
+ (NSString *)makeSignStringWithParams:(NSDictionary *)params key:(NSString *)key{
    NSString *string1 =[[NSString alloc]init];
    
    NSString *username = params[@"username"];
    NSString *password = params[@"password"];
    if (username.length < 1 || password.length < 1) {
        return @"";
    }
    
    NSString *keyValue = [NSString stringWithFormat:@"%@%@",username, password];
    NSString *string2 = [NSString stringWithFormat:@"%@%@",string1,keyValue];
    string1 = string2;
    
    NSString *sortedString = [NSString string];
    NSString *lastString = [NSString string];
    if (string1.length > 0) {
        sortedString = [NSString stringWithFormat:@"%@%@",key,string1];
        lastString = [sortedString substringWithRange:NSMakeRange(0, sortedString.length)];
        
    }else{
        sortedString = [NSString stringWithFormat:@"%@",key];
        lastString = [sortedString substringWithRange:NSMakeRange(0, sortedString.length)];
        
    }
    NSString *sign = [SSWL_PublicTool toMD5:lastString];
    return sign;
}


+ (NSString *_Nullable)getTimeStamps{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long int date = (long long int)time;
    return [NSString stringWithFormat:@"%lld",date];
}





//*** 4、字典转成字符串
+ (NSString *_Nullable)buildQueryString:(id _Nullable)dict sortArray:(NSArray *_Nullable)sortArray needUrlEncode:(BOOL)isEncode{
    if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
        NSMutableString *tempMsg = [NSMutableString string];
        for (id str in sortArray)
        {
            NSString *urlEncodedStr = nil;
            if ([[dict objectForKey:str] isKindOfClass:[NSString class]] && isEncode) {
                urlEncodedStr = [SSWL_PublicTool encodeString:[dict objectForKey:str]];
            }
            else{
                urlEncodedStr = [dict objectForKey:str];
            }
            [tempMsg appendString:[NSString stringWithFormat:@"%@=%@&", str, urlEncodedStr]];
        }
        NSString *queryMsg = [tempMsg substringToIndex:tempMsg.length - 1];
        return queryMsg;
    }else{
        [NSException raise:@"SDK Error" format:@"不可用数据类型 %@", [dict class]];
        return nil;
    }
}


//*** 5、获取主视图的根视图控制器
+ (UIViewController *_Nullable)getKeyWindowRootVcr{

 
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
    
}


//*** 6、判断是否是手机号码
+ (BOOL)isValidateTel:(NSString *_Nullable)tel
{
    ///^(13\d|14\d|15\d|17\d|18\d|19\d)\d{8}$/   ^1[3,4,5,7,8,9][0-9]{9}$
    NSString *patternTel = [SSWL_BasiceInfo sharedSSWL_BasiceInfo].regexModel.phone;
    if (patternTel.length < 1) {
        patternTel = @"^(13\\d|14\\d|15\\d|17\\d|18\\d|19\\d)\\d{8}$";
    }
    NSError *err = nil;
    NSRegularExpression *TelExp = [NSRegularExpression regularExpressionWithPattern:patternTel options:NSRegularExpressionCaseInsensitive error:&err];
    NSTextCheckingResult * isMatchTel = [TelExp firstMatchInString:tel options:0 range:NSMakeRange(0, [tel length])];
    return isMatchTel? YES: NO;
}


// 方法 判断是否有空格
+ (BOOL)isEmpty:(NSString *_Nullable)str{
    NSRange range = [str rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return YES; //yes代表包含空格
    }else {
        return NO; //反之
    }
}


//*** 7、密码加密处理
+ (NSString *_Nullable)generatePassword:(NSString *_Nullable)password
{
    return [SSWL_PublicTool toMD5:[NSString stringWithFormat:@"%@%@",password,[SSWL_PublicTool toMD5:password]]];
}


+ (NSString *_Nullable)encodeString:(NSString *_Nullable)unencodedString
{
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)unencodedString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    return encodedString;
}

+ (NSString *_Nullable)decodeString:(NSString *_Nullable)encodedString
{
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)encodedString, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}




/*保存token值*/
+ (void)saveToken:(NSString *_Nullable)token{
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*获取token值*/
+ (NSString *_Nullable)getToken{
    
    NSString *tokenStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    
    return tokenStr;
}

+ (void)showHUDWithViewController:(UIViewController *_Nullable)viewController Text:(NSString *_Nullable)text{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.label.text = text;
    [HUD hideAnimated:YES afterDelay:1];
}

+ (void)firstOpenApplication:(BOOL)firstOpen{
    [[NSUserDefaults standardUserDefaults] setBool:firstOpen forKey:@"firstOpenApplication"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getCurrenFirstOpenApplication{
    
    return [[NSUserDefaults standardUserDefaults]boolForKey:@"firstOpenApplication"];
}


/*记录用户是否激活*/
+ (void)saveActivateFlag:(BOOL)activated{
    [[NSUserDefaults standardUserDefaults] setBool:activated forKey:@"userActivate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 * 获取用户是否激活
 */
+ (BOOL)getCurrentActivateFlag{
    BOOL activated = [[NSUserDefaults standardUserDefaults]boolForKey:@"userActivate"];
    return activated;
    
}



+ (void)saveFirstOpen:(BOOL)firstOpen{
    [[NSUserDefaults standardUserDefaults] setBool:firstOpen forKey:@"userFirstOpen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getCurrenFirstOpen{
    BOOL first = [[NSUserDefaults standardUserDefaults]boolForKey:@"userFirstOpen"];
    return first;
    
}


+ (void)fastLoginWithSecretCode:(NSString *_Nullable)secret{
    [[NSUserDefaults standardUserDefaults] setObject:secret forKey:SSWL_fastLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *_Nullable)getSecretCodeForFastLogin{
    NSString *secret = [[NSUserDefaults standardUserDefaults] objectForKey:SSWL_fastLogin];
    return secret;
}

+ (void)fastLoginWithValue:(NSString *_Nullable)value key:(NSString *_Nullable)key{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id _Nullable)getFastLoginWithKey:(NSString *_Nullable)key{
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    return value;
}

+ (void)ifNeedAutoLogin:(BOOL)isAutoLogin{
    [[NSUserDefaults standardUserDefaults] setBool:isAutoLogin forKey:@"autoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isAuToLoginToUserChoose{
    BOOL isAutoLogin = [[NSUserDefaults standardUserDefaults]boolForKey:@"autoLogin"];
    return isAutoLogin;
    
}

+ (void)useToTouristLogin:(BOOL)isUse{
    [[NSUserDefaults standardUserDefaults] setBool:isUse forKey:@"touristLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (BOOL)getTouristState{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"touristLogin"];
}

+ (void)saveLanguage:(BOOL)isChiness{
    [[NSUserDefaults standardUserDefaults] setBool:isChiness forKey:@"userLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (BOOL)getLanguage{
    BOOL isChiness = [[NSUserDefaults standardUserDefaults] boolForKey:@"userLanguage"];
    
    return isChiness;
}

+ (void)mainWindowAddSubViewWindow:(UIWindow *)window{
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    if (mainWindow != nil && mainWindow.rootViewController != nil)
    {
        [mainWindow addSubview:window];
        [mainWindow makeKeyAndVisible];
    }
}

+ (UILabel *_Nullable)changeTextColor:(UIColor *_Nullable)changeColor ChangeTitle:(NSString *_Nullable)changeTitleText Titile:(NSString *_Nullable)titleText ToLabel:(UILabel *_Nullable)label{
    NSDictionary *subStringAttribute = @{
                                         NSForegroundColorAttributeName     : changeColor,
                                         NSFontAttributeName                : label.font
                                         };
    label.attributedText = [titleText toAttributedStringWithChangeWords:@[changeTitleText] andAttributes:@[subStringAttribute]];
    return label;
    
}

+ (void)stopSystemPopGestureRecognizerForNavigationController:(UINavigationController *_Nullable)navigationController{
    // 禁用返回手势
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

+ (void)showAlertToViewController:(UIViewController *)viewController alertControllerTitle:(NSString *)alertControllerTitle alertControllerMessage:(NSString *)message alertCancelTitle:(NSString *)cancelTitle alertReportTitle:(NSString *)reportTitle cancelHandler:(void(^__nullable)(UIAlertAction * _Nonnull action))cancelHandler reportHandler:(void(^__nullable)(UIAlertAction * _Nonnull action))reportHandler completion:(void (^ __nullable)(void))completion{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertControllerTitle message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelHandler];
    [alertController addAction:cancelAction];
    
    if (reportTitle || reportTitle.length > 0) {
        UIAlertAction *reportAction = [UIAlertAction actionWithTitle:reportTitle style:UIAlertActionStyleDefault handler:reportHandler];
        [alertController addAction:reportAction];
    }
    
    [viewController presentViewController:alertController animated:YES completion:completion];
    
}

+ (UIButton *)createBtnWithButton:(UIButton *)btn buttonType:(UIButtonType)buttonType frame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor image:(UIImage *)image normalTitle:(NSString *)normalTitle selectedTitle:(NSString *)selectedTitle highlightTile:(NSString *)highlightTile textAlignment:(NSTextAlignment)textAlignment selected:(BOOL)selected titleNormalColor:(UIColor *)titleNormalColor titleSelectedColor:(UIColor *)titleSelectedColor titleHighlightedColor:(UIColor *)titleHighlightedColor{
    
    if (!backgroundColor) {
        backgroundColor = SYNOColor;
    }
    if (!normalTitle || normalTitle.length < 1) {
        normalTitle = @"";
    }
    if (!highlightTile || highlightTile.length < 1) {
        highlightTile = normalTitle;
    }
    if (!selectedTitle || selectedTitle.length < 1) {
        selectedTitle = normalTitle;
    }
    if (!textAlignment) {
        textAlignment = 1;
    }
    if (!titleNormalColor) {
        titleNormalColor = SYWhiteColor;
    }
    if (!titleHighlightedColor) {
        titleHighlightedColor = SYWhiteColor;
    }
    if (!titleSelectedColor) {
        titleSelectedColor = SYWhiteColor;
    }
    
    
    btn = [UIButton buttonWithType:buttonType];
    btn.frame = frame;
    btn.backgroundColor = backgroundColor;
    if (image) {
        [btn setImage:image forState:UIControlStateNormal];
    }
    btn.titleLabel.textAlignment = textAlignment;
    [btn setTitle:normalTitle forState:UIControlStateNormal];
    [btn setTitle:highlightTile forState:UIControlStateHighlighted];
    [btn setTitle:selectedTitle forState:UIControlStateSelected];
    btn.selected = selected;
    [btn setTitleColor:titleHighlightedColor forState:UIControlStateHighlighted];
    [btn setTitleColor:titleSelectedColor forState:UIControlStateSelected];
    [btn setTitleColor:titleNormalColor forState:UIControlStateNormal];
    return btn;
}

+ (UILabel *)createLabelWithText:(NSString *)text textAlignment:(NSTextAlignment)textAlignment backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor borderColor:(UIColor *)borderColor borderWidth:(float)borderWidth fontSize:(float)fontSize alpha:(float)alpha numberOfLines:(int)numberOfLines tag:(int)tag{
    if (text.length < 1) {
        text = @"";
    }else if (!textAlignment){
        textAlignment = 1;
    }else if (!backgroundColor){
        backgroundColor = SYNOColor;
    }else if (!textColor){
        textColor = SYBlackColor;
    }else if (!fontSize){
        fontSize = 12.f;
    }else if (!alpha){
        alpha = 1.f;
    }else if (!numberOfLines){
        numberOfLines = 0;
    }else if (!borderColor){
        borderColor = SYNOColor;
    }else if (!borderWidth){
        borderWidth = .0f;
    }
    UILabel *label = [[UILabel alloc] init];
    label = [[UILabel alloc] init];
    label.numberOfLines = numberOfLines;
    label.textAlignment = textAlignment;
    label.textColor = textColor;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.text = text;
    label.alpha = alpha;
    label.backgroundColor = backgroundColor;
    label.layer.borderColor = borderColor.CGColor;
    label.layer.borderWidth = borderWidth;
    if (tag > 0){
        label.tag = tag;
    }
    return label;
}



+ (UITextField *)createUserNameTextFieldWithPlaceholder:(NSString *)placeholder clearButtonMode:(UITextFieldViewMode)clearButtonMode customClearButton:(NSString *)clearButtonName font:(float)fontSize keyboardType:(UIKeyboardType)keyboardType {
    
    if (placeholder.length < 1) {
        placeholder = @"";
    }
    
    if (!clearButtonMode) {
        clearButtonMode = UITextFieldViewModeNever;
    }
    
    if (!fontSize) {
        fontSize = 12.f;
    }
    
    if (!keyboardType) {
        keyboardType = UIKeyboardTypeDefault;
    }
    
    UITextField *textField = [[UITextField alloc] init];
//    _userTextFiled.translatesAutoresizingMaskIntoConstraints = NO;
    if (clearButtonName.length >0) {
        UIButton *button = [textField valueForKey:@"_clearButton"];
        [button setImage:get_BundleImage(clearButtonName) forState:UIControlStateNormal];
    }
    textField.clearButtonMode = clearButtonMode; 
    textField.placeholder =  placeholder;
    textField.font = [UIFont systemFontOfSize:fontSize];
    textField.keyboardType = keyboardType;
//    textField.delegate = self;
//        self.passTextField.secureTextEntry = YES;
    textField.returnKeyType = UIReturnKeyNext;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    return textField;
}


+ (UITextField *)createPasswordTextFieldWithPlaceholder:(NSString *)placeholder clearButtonMode:(UITextFieldViewMode)clearButtonMode font:(float)fontSize keyboardType:(UIKeyboardType)keyboardType {
    
    if (placeholder.length < 1) {
        placeholder = @"";
    }
    
    if (!clearButtonMode) {
        clearButtonMode = UITextFieldViewModeNever;
    }
    
    if (!fontSize) {
        fontSize = 12.f;
    }
    
    if (!keyboardType) {
        keyboardType = UIKeyboardTypeDefault;
    }
    
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder =  placeholder;
    textField.clearButtonMode = clearButtonMode;
    textField.font = [UIFont systemFontOfSize:fontSize];
    textField.keyboardType = keyboardType;
    //    textField.delegate = self;
    textField.secureTextEntry = YES;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    return textField;
}

+ (NSDictionary *)signKeyMustStringFromDictionary:(NSDictionary *)dictionary{
    NSMutableDictionary *parameterDictionary =[NSMutableDictionary dictionary];
    for (NSString *key in dictionary) {
        SYLog(@"key : %@, value : %@", key, [dictionary valueForKey:key]);
        if (![[dictionary valueForKey:key] isKindOfClass:[NSString class]]) {
            [parameterDictionary setValue:[NSString stringWithFormat:@"%@", [dictionary valueForKey:key]] forKey:key];
        }else{
            [parameterDictionary setValue:[dictionary valueForKey:key] forKey:key];
        }
        
    }
    NSString *signStr = [SSWL_PublicTool makeSignStringWithParams:parameterDictionary];
    SYLog(@"---sign:%@", signStr);
    [parameterDictionary setObject:signStr forKey:@"sign"];
    return [NSDictionary dictionaryWithDictionary:parameterDictionary];
    
}

+ (void)createFloatWindowIntoGameAndPostALCDeviceIdCompletion:(void (^)(BOOL))completion {
#pragma mark ------------------------------------------------ Post ALCPush DeviceId To Server
    
    

    if ([SSWL_PushInfo sharedSSWL_PushInfo].alcDeviceId.length > 0){
        [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] postServerUserDeviceId:[SSWL_PushInfo sharedSSWL_PushInfo].alcDeviceId completion:^(BOOL isSuccess, id  _Nullable respones) {
            if (isSuccess) {
                SYLog(@"AliCloud device id post success !");
                if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].isAppStatus) {
                    [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] createFloatWindow];
                }
                if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl.length > 0) {
                    [[SY_SSWL_FloatWindowTool sharedSY_SSWL_FloatWindowTool] creatHtmlGameWithUrl:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].requestUrl zUrl:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].urlString];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
                    if (completion) {
                        completion(isSuccess);
                    }
                    
                });
            }else{
                SYLog(@"AliCloud device id post failure !");
                if (completion) {
                    completion(isSuccess);
                }
            }
        } failure:^(NSError * _Nullable error) {
            SYLog(@"AliCloud device id post error : -------- %@", error);
            if (completion) {
                completion(NO);
            }
        }];
    }else{
        SYLog(@"Error : AliCloud device is NULL !");
        if (completion) {
            completion(NO);
        }
    }
}


+ (BOOL)isIphone_X{
    BOOL isIphone_x = NO;
    if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].device_Model isEqualToString:@"iPhone_X"]) {
        isIphone_x = YES;
    }
    return isIphone_x;
}

@end
