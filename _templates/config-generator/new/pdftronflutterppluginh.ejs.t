---
to: ios/Classes/PdftronFlutterPlugin.h
after: Hygen Generated Config Constants
inject: true
---
static NSString * const PT<%= h.changeCase.pascalCase(name) %>Key = @"<%= name %>";