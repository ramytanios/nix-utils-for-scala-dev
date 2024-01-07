{ lib, stdenv, jdk, scala-cli, graalvm-ce, clang, coreutils, llvmPackages
, openssl, s2n-tls, which, zlib }:
{ pname, version, src, supported-platforms ? [ "jvm" "graal" ] }:
with lib;
let

  supports-jvm = builtins.elem "jvm" supported-platforms;
  supports-graal = builtins.elem "graal" supported-platforms;

  native-packages =
    [ clang coreutils llvmPackages.libcxxabi openssl s2n-tls which zlib ];
  basic-packages = [ jdk scala-cli ];
  build-packages = basic-packages
    ++ (if (supports-graal) then native-packages else [ ]);

  # jvm app derivation
  jvm-app-drv = stdenv.mkDerivation {
    inherit version src;
    pname = "${pname}-jvm";
    buildInputs = build-packages;
    buildPhase = ''
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
    buildInputs = build-packages;
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

in mkMerge [
  (mkIf supports-jvm { jvm-drv = jvm-app-drv; })
  (mkIf supports-graal { graal-drv = graal-app-drv; })
]

