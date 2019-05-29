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

反编译的过程操纵了一个叫做apkdecoder的类，通过传入的参数进行了一些配置项的更改，之后核心在于

```
        decoder.setApkFile(new File(args[i]));
		try {
			decoder.decode();
		} catch (OutDirExistsException ex) {
		    ...
		}
```

### apkDecoder.decode()

```
public void decode() throws AndrolibException, IOException {
		File outDir = getOutDir();

		if (!mForceDelete && outDir.exists()) {
			throw new OutDirExistsException();
		}

		if (!mApkFile.isFile() || !mApkFile.canRead()) {
			throw new InFileNotFoundException();
		}

		try {
			OS.rmdir(outDir);
		} catch (BrutException ex) {
			throw new AndrolibException(ex);
		}
		outDir.mkdirs();

		if (hasSources()) {
			switch (mDecodeSources) {
			case DECODE_SOURCES_NONE:
				mAndrolib.decodeSourcesRaw(mApkFile, outDir, mDebug);
				break;
			case DECODE_SOURCES_SMALI:
				mAndrolib.decodeSourcesSmali(mApkFile, outDir, mDebug, mBakDeb);
				break;
			case DECODE_SOURCES_JAVA:
				mAndrolib.decodeSourcesJava(mApkFile, outDir, mDebug);
				break;
			}
		}

		if (hasResources()) {

			// read the resources.arsc checking for STORED vs DEFLATE
			// compression
			// this will determine whether we compress on rebuild or not.
			JarFile jf = new JarFile(mApkFile.getAbsoluteFile());
			JarEntry je = jf.getJarEntry("resources.arsc");
			if (je != null) {
				int compression = je.getMethod();
				mCompressResources = (compression != ZipEntry.STORED)
						&& (compression == ZipEntry.DEFLATED);
			}
			jf.close();

			switch (mDecodeResources) {
			case DECODE_RESOURCES_NONE:
				mAndrolib.decodeResourcesRaw(mApkFile, outDir);
				break;
			case DECODE_RESOURCES_FULL:
				mAndrolib.decodeResourcesFull(mApkFile, outDir, getResTable());
				break;
			}
		} else {
			// if there's no resources.asrc, decode the manifest without looking
			// up attribute references
			if (hasManifest()) {
				switch (mDecodeResources) {
				case DECODE_RESOURCES_NONE:
					mAndrolib.decodeManifestRaw(mApkFile, outDir);
					break;
				case DECODE_RESOURCES_FULL:
					mAndrolib.decodeManifestFull(mApkFile, outDir,
							getResTable());
					break;
				}
			}
		}

		mAndrolib.decodeRawFiles(mApkFile, outDir);
		writeMetaFile();
	}
```

decode的过程写的还蛮清楚的，分三步

- hasResources()

```
public boolean hasSources() throws AndrolibException {
		try {
			return mApkFile.getDirectory().containsFile("classes.dex");
		} catch (DirectoryException ex) {
			throw new AndrolibException(ex);
		}
	}
```

当apk文件拥有classes.dex文件的时候

执行
```
switch (mDecodeSources) {
			case DECODE_SOURCES_NONE:
				mAndrolib.decodeSourcesRaw(mApkFile, outDir, mDebug);
				break;
			case DECODE_SOURCES_SMALI:
				mAndrolib.decodeSourcesSmali(mApkFile, outDir, mDebug, mBakDeb);
				break;
			case DECODE_SOURCES_JAVA:
				mAndrolib.decodeSourcesJava(mApkFile, outDir, mDebug);
				break;
			}
```
mDecodeResources默认是SMALI

> smali 和 baksmali 则是针对 DEX 执行文件格式的汇编器和反汇编器，反汇编后 DEX 文件会产生.smali 后缀的代码文件，smali 代码拥有特定的格式与语法，smali 语言是对 Dalvik 虚拟机字节码的一种解释。

这也是apktool反编译生成的产物。

不过在这里我们也可以看出来，也是可以有其他两个选项的

#### AndroidLib.decodeSourcesSmali

```
public void decodeSourcesSmali(File apkFile, File outDir, boolean debug,
			boolean bakdeb) throws AndrolibException {
		try {
			File smaliDir = new File(outDir, SMALI_DIRNAME);
			OS.rmdir(smaliDir);
			smaliDir.mkdirs();
			LOGGER.info("Baksmaling...");
			SmaliDecoder.decode(apkFile, smaliDir, debug, bakdeb);
		} catch (BrutException ex) {
			throw new AndrolibException(ex);
		}
	}
```

调用了SmaliDecoder.decode

```
private void decode() throws AndrolibException {
		try {
			baksmali.disassembleDexFile(mApkFile.getAbsolutePath(),
					new DexFile(mApkFile), false, mOutDir.getAbsolutePath(),
					null, null, null, false, true, true, mBakDeb, false, false,
					0, false, false, null, false);
		} catch (IOException ex) {
			throw new AndrolibException(ex);
		}
	}
```

这里调用了baksmali.disassembleDexFile

```
public static void disassembleDexFile(String dexFilePath, DexFile dexFile, boolean deodex, String outputDirectory,
                                          String[] classPathDirs, String bootClassPath, String extraBootClassPath,
                                          boolean noParameterRegisters, boolean useLocalsDirective,
                                          boolean useSequentialLabels, boolean outputDebugInfo, boolean addCodeOffsets,
                                          boolean noAccessorComments, int registerInfo, boolean verify,
                                          boolean ignoreErrors, String inlineTable, boolean checkPackagePrivateAccess)
    {
        baksmali.noParameterRegisters = noParameterRegisters;
        baksmali.useLocalsDirective = useLocalsDirective;
        baksmali.useSequentialLabels = useSequentialLabels;
        baksmali.outputDebugInfo = outputDebugInfo;
        baksmali.addCodeOffsets = addCodeOffsets;
        baksmali.noAccessorComments = noAccessorComments;
        baksmali.deodex = deodex;
        baksmali.registerInfo = registerInfo;
        baksmali.bootClassPath = bootClassPath;
        baksmali.verify = verify;

        if (registerInfo != 0 || deodex || verify) {
            try {
                String[] extraBootClassPathArray = null;
                if (extraBootClassPath != null && extraBootClassPath.length() > 0) {
                    assert extraBootClassPath.charAt(0) == ':';
                    extraBootClassPathArray = extraBootClassPath.substring(1).split(":");
                }

                if (dexFile.isOdex() && bootClassPath == null) {
                    //ext.jar is a special case - it is typically the 2nd jar in the boot class path, but it also
                    //depends on classes in framework.jar (typically the 3rd jar in the BCP). If the user didn't
                    //specify a -c option, we should add framework.jar to the boot class path by default, so that it
                    //"just works"
                    if (extraBootClassPathArray == null && isExtJar(dexFilePath)) {
                        extraBootClassPathArray = new String[] {"framework.jar"};
                    }
                    ClassPath.InitializeClassPathFromOdex(classPathDirs, extraBootClassPathArray, dexFilePath, dexFile,
                            checkPackagePrivateAccess);
                } else {
                    String[] bootClassPathArray = null;
                    if (bootClassPath != null) {
                        bootClassPathArray = bootClassPath.split(":");
                    }
                    ClassPath.InitializeClassPath(classPathDirs, bootClassPathArray, extraBootClassPathArray,
                            dexFilePath, dexFile, checkPackagePrivateAccess);
                }

                if (inlineTable != null) {
                    inlineResolver = new CustomInlineMethodResolver(inlineTable);
                }
            } catch (Exception ex) {
                System.err.println("\n\nError occured while loading boot class path files. Aborting.");
                ex.printStackTrace(System.err);
                System.exit(1);
            }
        }

        File outputDirectoryFile = new File(outputDirectory);
        if (!outputDirectoryFile.exists()) {
            if (!outputDirectoryFile.mkdirs()) {
                System.err.println("Can't create the output directory " + outputDirectory);
                System.exit(1);
            }
        }

        if (!noAccessorComments) {
            syntheticAccessorResolver = new SyntheticAccessorResolver(dexFile);
        }

        //sort the classes, so that if we're on a case-insensitive file system and need to handle classes with file
        //name collisions, then we'll use the same name for each class, if the dex file goes through multiple
        //baksmali/smali cycles for some reason. If a class with a colliding name is added or removed, the filenames
        //may still change of course
        ArrayList<ClassDefItem> classDefItems = new ArrayList<ClassDefItem>(dexFile.ClassDefsSection.getItems());
        Collections.sort(classDefItems, new Comparator<ClassDefItem>() {
            public int compare(ClassDefItem classDefItem1, ClassDefItem classDefItem2) {
                return classDefItem1.getClassType().getTypeDescriptor().compareTo(classDefItem1.getClassType().getTypeDescriptor());
            }
        });

        ClassFileNameHandler fileNameHandler = new ClassFileNameHandler(outputDirectoryFile, ".smali");

        for (ClassDefItem classDefItem: classDefItems) {
            /**
             * The path for the disassembly file is based on the package name
             * The class descriptor will look something like:
             * Ljava/lang/Object;
             * Where the there is leading 'L' and a trailing ';', and the parts of the
             * package name are separated by '/'
             */

            String classDescriptor = classDefItem.getClassType().getTypeDescriptor();

            //validate that the descriptor is formatted like we expect
            if (classDescriptor.charAt(0) != 'L' ||
                classDescriptor.charAt(classDescriptor.length()-1) != ';') {
                System.err.println("Unrecognized class descriptor - " + classDescriptor + " - skipping class");
                continue;
            }

            File smaliFile = fileNameHandler.getUniqueFilenameForClass(classDescriptor);

            //create and initialize the top level string template
            ClassDefinition classDefinition = new ClassDefinition(classDefItem);

            //write the disassembly
            Writer writer = null;
            try
            {
                File smaliParent = smaliFile.getParentFile();
                if (!smaliParent.exists()) {
                    if (!smaliParent.mkdirs()) {
                        System.err.println("Unable to create directory " + smaliParent.toString() + " - skipping class");
                        continue;
                    }
                }

                if (!smaliFile.exists()){
                    if (!smaliFile.createNewFile()) {
                        System.err.println("Unable to create file " + smaliFile.toString() + " - skipping class");
                        continue;
                    }
                }

                BufferedWriter bufWriter = new BufferedWriter(new OutputStreamWriter(
                        new FileOutputStream(smaliFile), "UTF8"));

                writer = new IndentingWriter(bufWriter);
                classDefinition.writeTo((IndentingWriter)writer);
            } catch (Exception ex) {
                System.err.println("\n\nError occured while disassembling class " + classDescriptor.replace('/', '.') + " - skipping class");
                ex.printStackTrace();
                smaliFile.delete();
            }
            finally
            {
                if (writer != null) {
                    try {
                        writer.close();
                    } catch (Throwable ex) {
                        System.err.println("\n\nError occured while closing file " + smaliFile.toString());
                        ex.printStackTrace();
                    }
                }
            }

            if (!ignoreErrors && classDefinition.hadValidationErrors()) {
                System.exit(1);
            }
        }
    }
```

这里就到了核心部分，这里比较长，需要提炼一下。

首先
```
if (extraBootClassPath != null && extraBootClassPath.length() > 0) {
                    assert extraBootClassPath.charAt(0) == ':';
                    extraBootClassPathArray = extraBootClassPath.substring(1).split(":");
                }
```
这一段是不需要的，因为这个extraBootClassPath是个null

```
if (dexFile.isOdex() && bootClassPath == null) {
```

这一段是固定的false，因为这个bootClassPath也是个null

因此就会走入
```
String[] bootClassPathArray = null;
                    if (bootClassPath != null) {
                        bootClassPathArray = bootClassPath.split(":");
                    }
                    ClassPath.InitializeClassPath(classPathDirs, bootClassPathArray, extraBootClassPathArray,
                            dexFilePath, dexFile, checkPackagePrivateAccess);
```

这一步就很关键了，因为执行了

```
ClassPath.InitializeClassPath(...);
```

这个api的作用如下

```
/**
     * Initialize the class path using the dependencies from an odex file
     * @param classPathDirs The directories to search for boot class path files
     * @param extraBootClassPathEntries any extra entries that should be added after the entries that are read
     * from the odex file
     * @param dexFilePath The path of the dex file (used for error reporting purposes only)
     * @param dexFile The DexFile to load - it must represents an odex file
     */
```

使用一个odex文件的依赖来初始化文件的路径。

```
String[] bootClassPath = new String[odexDependencies.getDependencyCount()];
        for (int i=0; i<bootClassPath.length; i++) {
            String dependency = odexDependencies.getDependency(i);

            if (dependency.endsWith(".odex")) {
                int slashIndex = dependency.lastIndexOf("/");

                if (slashIndex != -1) {
                    dependency = dependency.substring(slashIndex+1);
                }
            } else if (dependency.endsWith("@classes.dex")) {
                Matcher m = dalvikCacheOdexPattern.matcher(dependency);

                if (!m.find()) {
                    throw new ExceptionWithContext(String.format("Cannot parse dependency value %s", dependency));
                }

                dependency = m.group(1);
            } else {
                throw new ExceptionWithContext(String.format("Cannot parse dependency value %s", dependency));
            }

            bootClassPath[i] = dependency;
        }
```

这是找到依赖的方法，一是直接通过判断是否以odex结尾，是的话直接截取，二是通过匹配查找，返回找到的第一个。

之后又调用

```
theClassPath.initClassPath(classPathDirs, bootClassPath, extraBootClassPathEntries, dexFilePath, dexFile,
                checkPackagePrivateAccess);
```

//这调用的也太深了吧，我好想吐槽啊

这一步的目的是执行

```
loadDexFile(file.getPath(), dexFile);
```

事实上，在调用initClassPath的时候，就在动作的末位有了这个loadDexFile的动作