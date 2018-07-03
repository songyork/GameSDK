//
//  SSWL_PublickTool.h
//  SSWLSDK
//
//  Created by SDK on 2018/3/19.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSWL_PublicTool : NSObject




/**
 获取bundle文件

 @return bundle类型
 */
+ (NSBundle *_Nullable)getResourceBundle;



/**
 获取bunle文件里面的图片

 @param bundle getResourceBundle返回类型
 @param name 图片名字
 @param type 类型(png,jpg)
 @return UIImage
 */
+ (UIImage *_Nullable)getImageFromBundle:(NSBundle *_Nullable)bundle
                                withName:(NSString *_Nullable)name
                                withType:(NSString *_Nullable)type;



/**
 获取bundle.dat文件

 @param bundle bundle
 @param name 文件名
 @return 字符串
 */
+ (NSString *)getSourceFromBundle:(NSBundle *_Nullable)bundle
                         withName:(NSString *_Nullable)name;

/**
 将字符串转换成md5

 @param targetString 需要转换的字符串
 @return MD5字符串
 */
+ (NSString *_Nullable)toMD5:(NSString *_Nullable)targetString;


/**
 请求签名

 @param params 需要转换的参数
 @return 转换完成的字符串
 */
+ (NSString *_Nullable)makeSignStringWithParams:(NSDictionary *_Nullable)params;



/**
 bbs加密签名

 @param params 需要转换的参数
 @param key 单独的key
 @return 转换完成的字符串
 */
+ (NSString *_Nullable)makeSignStringWithParams:(NSDictionary *_Nullable)params
                                           key:(NSString *_Nullable)key;




/**
 获取当前时间戳

 @return string时间戳
 */
+ (NSString *_Nullable)getTimeStamps;



/**
 字典转成字符串

 @param dict 目标字典
 @param allKeysArray key数组(nil表示需要排序)
 @param isEncode 是否需要URLencode
 @return 排序后的字符串
 */
+ (NSString *_Nullable)buildQueryString:(id _Nullable)dict
                           allKeysArray:(NSArray *_Nullable)allKeysArray
                          needUrlEncode:(BOOL)isEncode;




/**
 获取主视图的根视图控制器

 @return 当前最上层根视图控制器
 */
+ (UIViewController *_Nullable)getKeyWindowRootVcr;



/**
 判断是否是手机号码

 @param tel 电话号码
 @return BOOL
 */
+ (BOOL)isValidateTel:(NSString *_Nullable)tel;



/**
 储存第一次打开应用

 @param firstOpen bool
 */
+ (void)firstOpenApplication:(BOOL)firstOpen;



/**
 获取第一次打开应用

 @return bool
 */
+ (BOOL)getCurrenFirstOpenApplication;


/**/

/**
 第一次使用一键注册

 @param firstOpen bool
 */
+ (void)saveFirstOpen:(BOOL)firstOpen;


/**
 是否第一次使用一键注册

 @return bool
 */
+ (BOOL)getCurrenFirstOpen;



/*记录激活*/
+ (void)saveActivateFlag:(BOOL)activated;

/*获取激活*/
+ (BOOL)getCurrentActivateFlag;

/**
 是否需要自动登录

 @param isAutoLogin bool
 */
+ (void)ifNeedAutoLogin:(BOOL)isAutoLogin;

/*是否是自动登录状态*/

/**
 是否是自动登录

 @return bool
 */
+ (BOOL)isAuToLoginToUserChoose;


/**
 密码MD5加密处理

 @param password 密码
 @return MD5加密后的字符串
 */
+ (NSString *_Nullable)generatePassword:(NSString *_Nullable)password;



/**
 保存一键登录状态

 @param isUse 记录状态
 */
+ (void)useToTouristLogin:(BOOL)isUse;


/**
 获取游客登录状态
 
 @return 状态
 */
+ (BOOL)getTouristState;


/*
 * 自动登录保存用户名
 */
+ (void)fastLoginWithSecretCode:(NSString *_Nullable)secret;

/**
 * 取出自动登录保存的用户名
 */
+ (NSString *_Nullable)getSecretCodeForFastLogin;

/*
 * 保存自动登录的用户名和密码
 * @param value : 密码
 */
+ (void)fastLoginWithValue:(NSDictionary *_Nullable)value
                       key:(NSString *_Nullable)key;

/*
 * 取出自动登录是保存的账号密码
 */
+ (id _Nullable)getFastLoginWithKey:(NSString *_Nullable)key;


/**
 encode转码

 @param unencodedString 目标string
 @return encodestring
 */
+ (NSString *_Nullable)encodeString:(NSString *_Nullable)unencodedString;


/**
 encode解码

 @param encodedString targetstring
 @return decodestring
 */
+ (NSString *_Nullable)decodeString:(NSString *_Nullable)encodedString;


/**
 保存token值

 @param token token
 */
+ (void)saveToken:(NSString *_Nullable)token;


/**
 获取token值

 @return token
 */
+ (NSString *_Nullable)getToken;


/**
 HUD提示

 @param viewController 当前viewController
 @param text HUD文本
 */
+ (void)showHUDWithViewController:(UIViewController *_Nullable)viewController
                             Text:(NSString *_Nullable)text;


/**
 禁用系统返回手势

 @param navigationController targetNavigationController
 */
+ (void)stopSystemPopGestureRecognizerForNavigationController:(UINavigationController *_Nullable)navigationController;



/**
 alertViewController

 @param viewController targetViewController
 @param alertControllerTitle title文本
 @param message detailMessage文本
 @param cancelTitle cancel文本
 @param reportTitle report文本
 @param cancelHandler cancelBlock
 @param reportHandler reportBlock
 @param completion Block
 */
+ (void)showAlertToViewController:(UIViewController *_Nullable)viewController
             alertControllerTitle:(NSString *_Nullable)alertControllerTitle
           alertControllerMessage:(NSString *_Nullable)message
                 alertCancelTitle:(NSString *_Nullable)cancelTitle
                 alertReportTitle:(NSString *_Nullable)reportTitle
                    cancelHandler:(void(^__nullable)(UIAlertAction * _Nonnull action))cancelHandler
                    reportHandler:(void(^__nullable)(UIAlertAction * _Nonnull action))reportHandler
                       completion:(void (^ __nullable)(void))completion;



/**
 button

 @param btn targetButton
 @param buttonType buttonType
 @param frame frame
 @param backgroundColor backgroundColor
 @param image setImage
 @param normalTitle selectedNormallitle
 @param selectedTitle selectedTitle
 @param highlightTile selectedHighlightTitle
 @param textAlignment textAlignment
 @param selected isSelected
 @param titleNormalColor selectNormalColor
 @param titleSelectedColor selectColor
 @param titleHighlightedColor selectHighlightedColot
 @return btn
 */
+ (UIButton *_Nonnull)createBtnWithButton:(UIButton *_Nullable)btn
                               buttonType:(UIButtonType)buttonType
                                    frame:(CGRect)frame
                          backgroundColor:(UIColor *_Nullable)backgroundColor
                                    image:(UIImage *_Nullable)image
                              normalTitle:(NSString *_Nullable)normalTitle
                            selectedTitle:(NSString *_Nullable)selectedTitle
                            highlightTile:(NSString *_Nullable)highlightTile
                            textAlignment:(NSTextAlignment)textAlignment
                                 selected:(BOOL)selected
                         titleNormalColor:(UIColor *_Nullable)titleNormalColor
                       titleSelectedColor:(UIColor *_Nullable)titleSelectedColor
                    titleHighlightedColor:(UIColor *_Nullable)titleHighlightedColor;



/**
 创建UserNameTextField

 @param placeholder 占位字符
 @param clearButtonMode 清除建
 @param fontSize 字体大小
 @param keyboardType 确认键
 @return textfield
 */
+ (UITextField *)createUserNameTextFieldWithPlaceholder:(NSString * __nullable)placeholder
                                        clearButtonMode:(UITextFieldViewMode)clearButtonMode
                                      customClearButton:(NSString *)clearButtonName
                                                   font:(float)fontSize
                                           keyboardType:(UIKeyboardType)keyboardType;


/**
 创建passwordTextField

 @param placeholder 占位字符
 @param clearButtonMode 清除建
 @param fontSize 字体大小
 @param keyboardType 确认键
 @return textfield
 */
+ (UITextField *)createPasswordTextFieldWithPlaceholder:(NSString * __nullable)placeholder
                                        clearButtonMode:(UITextFieldViewMode)clearButtonMode
                                                   font:(float)fontSize
                                           keyboardType:(UIKeyboardType)keyboardType;

/**
 * 保存上次登录是返回的语言选项
 */
+ (void)saveLanguage:(BOOL)isChiness;

+ (BOOL)getLanguage;


/**
 是否有空格

 @param string targetString
 @return bool isEmpty
 */
+ (BOOL)isEmpty:(NSString *_Nullable)string;


/**
 添加到主window上面
 
 @param window 需要被添加的window
 */
+ (void)mainWindowAddSubViewWindow:(UIWindow *_Nullable)window;



/**
 利用富文本改变label的字体颜色

 @param changeColor targetColor
 @param changeTitleText targetText
 @param titleText allTitleText
 @param label targetLabel
 @return label
 */
+ (UILabel *_Nullable)changeTextColor:(UIColor *_Nullable)changeColor
                          ChangeTitle:(NSString *_Nullable)changeTitleText
                               Titile:(NSString *_Nullable)titleText
                              ToLabel:(UILabel *_Nullable)label;



/**
 创建label

 @param text 文字描述
 @param textAlignment 对齐方向
 @param backgroundColor 背景颜色
 @param textColor 字体颜色
 @param borderColor 边框颜色
 @param borderWidth 边框宽度
 @param fontSize 字体大小
 @param alpha 透明度
 @param numberOfLines 多少行
 @param tag tag
 @return label
 */
+ (UILabel *)createLabelWithText:(NSString *)text
                   textAlignment:(NSTextAlignment)textAlignment
                 backgroundColor:(UIColor *)backgroundColor
                       textColor:(UIColor *)textColor
                     borderColor:(UIColor *)borderColor
                     borderWidth:(float)borderWidth
                        fontSize:(float)fontSize
                           alpha:(float)alpha
                   numberOfLines:(int)numberOfLines
                             tag:(int)tag;

/**
 检测是否是字符串并签名

 @param dictionary 参数字典
 @return dictionary
 */
+ (NSDictionary *)signKeyMustStringFromDictionary:(NSDictionary *)dictionary;


/**
 进入游戏, 是否是H5, 是否开启悬浮窗, 上传ALC Push 设备号

 @param completion finished block
 */
+ (void)createFloatWindowIntoGameAndPostALCDeviceIdCompletion:(void(^_Nullable)(BOOL canIntoGame))completion;



/**
 是否是iPhone X

 @return bool
 */
+ (BOOL)isIphone_X;



@end
