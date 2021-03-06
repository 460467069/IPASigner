//
//  IPASigner.m
//  IPASigner
//
//  Created by 冷秋 on 2019/9/17.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPASigner.h"

@implementation IPASigner

+ (void)addGeneralArgumentsToCommand:(CLCommand *)command {
	command.setQuery(@"bundle-id").setAbbr('i').optional().setExample(@"com.xxx.xxx").setExplain(@"Modify CFBundleIdentifier");
	command.setQuery(@"bundle-version").optional().setExample(@"1.0.0").setExplain(@"Modify CFBundleVersion");
	command.setQuery(@"build-version").optional().setExample(@"1000").setExplain(@"Modify CFBundleShortVersionString");
	command.setQuery(@"bundle-display-name").optional().setExample(@"NAME").setExplain(@"Modify CFBundleDisplayName");
	command.setFlag(@"support-all-devices").setAbbr('a').setExplain(@"Remove Info's value for keyed UISupportDevices.");
	command.setFlag(@"file-sharing").setExplain(@"Enable iTunes file sharing");
	command.setFlag(@"no-file-sharing").setExplain(@"Disable iTunes file sharing");
	
	command.setFlag(@"rm-plugins").setExplain(@"Delete all app extensions.");
	command.setFlag(@"rm-watches").setExplain(@"Delete all watch apps.");
	command.setFlag(@"rm-ext").setAbbr('r').setExplain(@"Delete all watch apps and plugins.");
	
	command.setQuery(@"entitlements").setAbbr('e').optional().setMultiType(CLQueryMultiTypeMoreKeyValue).setExplain(@"Sign with entitlements, bundle_id=entitlement_path");
	
	command.addRequirePath(@"input").setExample(@"/path/to/input.ipa").setExplain(@"Input ipa path.");
	command.addOptionalPath(@"output").setExample(@"/path/to/output.ipa").setExplain(@"Output ipa path.");
}

+ (ISIPASignerOptions *)genSignOptionsFromProcess:(CLProcess *)process {
    ISIPASignerOptions *options = [ISIPASignerOptions new];
	options.CFBundleIdentifier = process.queries[@"bundle-id"];
	options.CFBundleVersion = process.queries[@"bundle-version"];
	options.CFBundleDisplayName = process.queries[@"bundle-display-name"];
	options.CFBundleShortVersionString = process.queries[@"build-version"];
	options.deletePlugIns = [process flag:@"rm-plugins"];
	options.deleteWatches = [process flag:@"rm-watches"];
	options.deleteExtensions = [process flag:@"rm-ext"];
	options.supportAllDevices = [process flag:@"support-all-devices"];
	
	if ([process flag:@"file-sharing"] && [process flag:@"no-file-sharing"]) {
		CLError(@"You must type in one of --file-sharing and --no-file-sharing, or without anyone.");
		CLExit(EXIT_FAILURE);
	}
	
	if ([process flag:@"file-sharing"]) {
		options.enableiTunesFileSharing = YES;
	}
	if ([process flag:@"no-file-sharing"]) {
		options.disableiTunesFileSharing = YES;
	}
    return options;
}


+ (MUPath *)inputPathFromProcess:(CLProcess *)process {
	MUPath *input = [MUPath pathWithString:[process pathForIndex:0]];
	return input;
}

+ (MUPath *)outputPathFromProcess:(CLProcess *)process {
	MUPath *input = [MUPath pathWithString:[process pathForIndex:0]];
	MUPath *output = [process pathForIndex:1] ? [MUPath pathWithString:[process pathForIndex:1]] : [input pathByReplacingPathExtension:@"signed.ipa"];
	return output;
}

@end
