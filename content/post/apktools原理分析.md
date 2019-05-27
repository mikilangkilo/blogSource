---
title: "Apktools原理分析"
date: 2019-05-25T22:12:59+08:00
tags: 安全
---

# apktools源码

```
https://github.com/brutall/brut.apktool.git
```

# 阅读顺序

最基础的入口就是没有任何后缀的brut.apktool中的入口函数

```
public static void main(String[] args) throws IOException,
			InterruptedException, BrutException {
		try {
			Verbosity verbosity = Verbosity.NORMAL;
			int i;
			for (i = 0; i < args.length; i++) {
				String opt = args[i];

				if (opt.startsWith("--version") || (opt.startsWith("-version"))) {
					version_print();
					System.exit(1);
				}
				if (!opt.startsWith("-")) {
					break;
				}
				if ("-v".equals(opt) || "--verbose".equals(opt)) {
					if (verbosity != Verbosity.NORMAL) {
						throw new InvalidArgsError();
					}
					verbosity = Verbosity.VERBOSE;
				} else if ("-q".equals(opt) || "--quiet".equals(opt)) {
					if (verbosity != Verbosity.NORMAL) {
						throw new InvalidArgsError();
					}
					verbosity = Verbosity.QUIET;
				} else {
					throw new InvalidArgsError();
				}
			}
			setupLogging(verbosity);

			if (args.length <= i) {
				throw new InvalidArgsError();
			}
			String cmd = args[i];
			args = Arrays.copyOfRange(args, i + 1, args.length);

			if ("d".equals(cmd) || "decode".equals(cmd)) {
				cmdDecode(args);
			} else if ("b".equals(cmd) || "build".equals(cmd)) {
				cmdBuild(args);
			} else if ("if".equals(cmd) || "install-framework".equals(cmd)) {
				cmdInstallFramework(args);
			} else if ("publicize-resources".equals(cmd)) {
				cmdPublicizeResources(args);
			} else {
				throw new InvalidArgsError();
			}
		} catch (InvalidArgsError ex) {
			usage();
			System.exit(1);
		}
	}
```

从这一段代码中可以看出apktools的一些命令

> -d 反编译

> -b 回编译

> -if 安装框架

> -publicize-resources 处理arsc文件

## 反编译过程

```
private static void cmdDecode(String[] args) throws InvalidArgsError,
			AndrolibException {
		ApkDecoder decoder = new ApkDecoder();

		int i;
		for (i = 0; i < args.length; i++) {
			String opt = args[i];
			if (!opt.startsWith("-")) {
				break;
			}
			if ("-s".equals(opt) || "--no-src".equals(opt)) {
				decoder.setDecodeSources(ApkDecoder.DECODE_SOURCES_NONE);
			} else if ("-d".equals(opt) || "--debug".equals(opt)) {
				decoder.setDebugMode(true);
			} else if ("-b".equals(opt) || "--no-debug-info".equals(opt)) {
				decoder.setBaksmaliDebugMode(false);
			} else if ("-t".equals(opt) || "--frame-tag".equals(opt)) {
				i++;
				if (i >= args.length) {
					throw new InvalidArgsError();
				}
				decoder.setFrameworkTag(args[i]);
			} else if ("-f".equals(opt) || "--force".equals(opt)) {
				decoder.setForceDelete(true);
			} else if ("-r".equals(opt) || "--no-res".equals(opt)) {
				decoder.setDecodeResources(ApkDecoder.DECODE_RESOURCES_NONE);
			} else if ("--keep-broken-res".equals(opt)) {
				decoder.setKeepBrokenResources(true);
			} else if ("--frame-path".equals(opt)) {
				i++;
        if (i >= args.length) {
          throw new InvalidArgsError();
        }
				decoder.setFrameworkDir(args[i]);
			} else {
				throw new InvalidArgsError();
			}
		}

		String outName = null;
		if (args.length == i + 2) {
			outName = args[i + 1];
		} else if (args.length == i + 1) {
			outName = args[i];
			outName = outName.endsWith(".apk") ? outName.substring(0,
					outName.length() - 4) : outName + ".out";
			outName = new File(outName).getName();
		} else {
			throw new InvalidArgsError();
		}
		File outDir = new File(outName);
		decoder.setOutDir(outDir);
		decoder.setApkFile(new File(args[i]));

		try {
			decoder.decode();
		} catch (OutDirExistsException ex) {
			System.out
					.println("Destination directory ("
							+ outDir.getAbsolutePath()
							+ ") "
							+ "already exists. Use -f switch if you want to overwrite it.");
			System.exit(1);
		} catch (InFileNotFoundException ex) {
			System.out.println("Input file (" + args[i] + ") "
					+ "was not found or was not readable.");
			System.exit(1);
		} catch (CantFindFrameworkResException ex) {
			System.out
					.println("Can't find framework resources for package of id: "
							+ String.valueOf(ex.getPkgId())
							+ ". You must install proper "
							+ "framework files, see project website for more info.");
			System.exit(1);
		} catch (IOException ex) {
			System.out
					.println("Could not modify file. Please ensure you have permission.");
			System.exit(1);
		}

	}
```





