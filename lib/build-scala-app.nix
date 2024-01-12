pkgs:
{ pname, version, src, supported-platforms ? [ "jvm" "graal" ], sha256 }:
with pkgs;
let

  supports-jvm = builtins.elem "jvm" supported-platforms;
  supports-graal = builtins.elem "graal" supported-platforms;

  native-packages =
    [ clang coreutils llvmPackages.libcxxabi openssl s2n-tls which zlib ];
  basic-packages = [ jdk scala-cli ];
  build-packages = basic-packages
    ++ (if supports-graal then native-packages else [ ]);

  # coursier deps
  coursier-cache-drv = stdenv.mkDerivation {
    inherit src;
    pname = "coursier-cache";

    buildInputs = build-packages;

    SCALA_CLI_HOME = "./scala-cli-home";
    COURSIER_CACHE = "./coursier-cache/v1";
    COURSIER_ARCHIVE_CACHE = "./coursier-cache/arc";
    COURSIER_JVM_CACHE = "./coursier-cache/jvm";

    buildPhase = ''
      mkdir scala-cli-home 
      mkdir -p coursier-cache/v1
      mkdir -p coursier-cache/arc
      mkdir -p coursier-cache/jvm
      scala-cli compile . --java-home=${jdk} --server=false
    '';

    installPhase = ''
      mkdir -p $out/coursier-cache 
      cp -R ./coursier-cache $out
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = sha256;

  };

  # jvm app derivation
  jvm-app-drv = stdenv.mkDerivation {
    inherit version src;
    pname = "${pname}-jvm";

    buildInputs = build-packages ++ [ coursier-cache-drv ];

    JAVA_HOME = "${jdk}";
    SCALA_CLI_HOME = "./scala-cli-home";
    COURSIER_CACHE = "${coursier-cache-drv}/coursier-cache/v1";
    COURSIER_ARCHIVE_CACHE = "${coursier-cache-drv}/coursier-cache/arc";
    COURSIER_JVM_CACHE = "${coursier-cache-drv}/coursier-cache/jvm";

    buildPhase = ''
      mkdir scala-cli-home
      scala-cli --power \
        package . \
        --standalone \
        --java-home=${jdk} \
        --server=false \
        -o ${pname}
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp ${pname} $out/bin
    '';
  };

  # graal app derivation
  graal-app-drv = stdenv.mkDerivation {
    inherit version src;
    pname = "${pname}-graal";
    buildInputs = build-packages ++ [ coursier-cache-drv ];

    JAVA_HOME = "${jdk}";
    SCALA_CLI_HOME = "./scala-cli-home";
    COURSIER_CACHE = "${coursier-cache-drv}/coursier-cache/v1";
    COURSIER_ARCHIVE_CACHE = "${coursier-cache-drv}/coursier-cache/arc";
    COURSIER_JVM_CACHE = "${coursier-cache-drv}/coursier-cache/jvm";

    buildPhase = ''
      mkdir scala-cli-home
      scala-cli --power \
        package . \
        --native-image \
        --java-home ${graalvm-ce} \
        --server=false \
        --graalvm-args --verbose \
        --graalvm-args --native-image-info \
        --graalvm-args --no-fallback \
        --graalvm-args --initialize-at-build-time=scala.runtime.Statics$$VM \
        --graalvm-args --initialize-at-build-time=scala.Symbol \
        --graalvm-args --initialize-at-build-time=scala.Symbol$$ \
        --graalvm-args -H:-CheckToolchain \
        --graalvm-args -H:+ReportExceptionStackTraces \
        --graalvm-args -H:-UseServiceLoaderFeature \
        -o ${pname}
    '';

    installPhase = ''
      mkdir -p $out/bin 
      cp ${pname} $out/bin
    '';
  };

in with pkgs.lib;
mkMerge [
  (mkIf supports-jvm { jvm-drv = jvm-app-drv; })
  (mkIf supports-graal { graal-drv = graal-app-drv; })
]

