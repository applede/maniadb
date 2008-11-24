//
//  Levenshtein.m
//  ManiaDB
//
//  Created by Appledelhi on 11/20/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "Levenshtein.h"

#define d(i, j) d[(i) * n + (j)]

inline int min(a, b, c)
{
  int min = a;
  if (b < min)
    min = b;
  if (c < min)
    min = c;
  return min;
}

inline int max(a, b)
{
  if (a > b)
    return a;
  return b;
}

inline int cost(a, b)
{
  if (a == b)
    return 0;
  if (tolower(a) == tolower(b))
    return 1;
  return 10;
}

@implementation Levenshtein

- (int)distance:(NSString*)stra to:(NSString*)strb
{
  const char *a = [stra UTF8String];
  const char *b = [strb UTF8String];
  int m = strlen(a);
  int n = strlen(b);
  int *d = malloc((m + 1)*(n + 1)*sizeof(int));
  int i;
  int j;
  for (i = 0; i <= m; i++) {
    d(i, 0) = i * 10;
  }
  for (j = 0; j < n; j++) {
    d(0, j) = j * 10;
  }
  for (i = 1; i <= m; i++) {
    for (j = 1; j <= n; j++) {
      d(i, j) = min(d(i - 1, j) + 10,
                    d(i, j - 1) + 10,
                    d(i - 1, j - 1) + cost(a[i - 1], b[i - 1]));
    }
  }
  int result = d(m, n);
  free(d);
  if (result == max(m, n))
    return 100000;
  return result;
}

@end
