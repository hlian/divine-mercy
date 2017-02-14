//
//  Network.h
//  divinemercy
//
//  Created by hao on 2/13/17.
//
//

#ifndef Network_h
#define Network_h

static NSString *kAPI(NSString *s) {
    NSURLComponents *comp = [NSURLComponents componentsWithString:@"https://basilica.horse/api"];
    comp.path = [comp.path stringByAppendingPathComponent:s];
    return comp.URL.absoluteString;
}

#endif /* Network_h */
