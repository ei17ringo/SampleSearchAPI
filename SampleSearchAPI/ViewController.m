//
//  ViewController.m
//  SampleSearchAPI
//
//  Created by Eriko Ichinohe on 2015/02/02.
//  Copyright (c) 2015年 Eriko Ichinohe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
@private
    NSArray *_events;
    BOOL isTarget;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLSessionConfiguration *urlSessionConfiguration;
    urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:self delegateQueue:nil];
   
    //「マンゴー」で検索してます
    NSURL *url = [NSURL URLWithString:@"https://api.datamarket.azure.com/Bing/Search/v1/Web?Query=%27%E3%83%9E%E3%83%B3%E3%82%B4%E3%83%BC%27"];
    

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionDataTask *urlSessionDataTask;
    
    
    urlSessionDataTask = [urlSession dataTaskWithURL:url
                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                    
                                    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
                                    
                                    //デリゲートの設定
                                    parser.delegate = self;
                                    
                                    //解析開始
                                    [parser parse];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                    });
                                }];
    [urlSessionDataTask resume];

    
    
}

//ベーシック認証があれば呼ばれる関数
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    
    NSLog(@"Basic認証するよ");
    
    //両方にBingのプライマリーキーを指定してください
    NSString *username = @"Your Bing Primary Key";
    NSString *password = @"Your Bing Primary Key";
    
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengeUseCredential;
    NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
    completionHandler(disposition, credential);
    
}


//デリゲートメソッド(解析開始時)
-(void) parserDidStartDocument:(NSXMLParser *)parser{
    
    NSLog(@"解析開始");
    
    //解析の初期化処理
    isTarget = NO;
}

//デリゲートメソッド(要素の開始タグを読み込んだ時)
- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict{
    
    //NSLog(@"要素の開始タグを読み込んだ:%@",elementName);
    
    if([elementName isEqualToString:@"d:Title"]){
        
        isTarget = YES;     //データを取得するターゲットである事を保持する
        
    }
    
}

//デリゲートメソッド(タグ以外のテキストを読み込んだ時)
- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    //NSLog(@"タグ以外のテキストを読み込んだ:%@", string);
    
    if(isTarget){           //データを取得するターゲットの場合
        
        NSLog(@"Title=%@",string);   //読み込んだテキストを取得結果として保持する
    }
}

//デリゲートメソッド(要素の終了タグを読み込んだ時)
- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName{
    
    //NSLog(@"要素の終了タグを読み込んだ:%@",elementName);
    
    isTarget = NO;
}

//デリゲートメソッド(解析終了時)
-(void) parserDidEndDocument:(NSXMLParser *)parser{
    
    NSLog(@"解析終了");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
