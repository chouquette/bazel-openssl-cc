"""Rule that lets select() tell GNU-style compilers apart, like @rules_cc//cc/compiler."""

load("@rules_cc//cc:find_cc_toolchain.bzl", "CC_TOOLCHAIN_ATTRS", "find_cpp_toolchain", "use_cc_toolchain")

_GNU_COMPILERS = ("mingw-gcc", "gcc", "clang")

def _gnu_compiler_flag_impl(ctx):
    toolchain = find_cpp_toolchain(ctx)
    return [config_common.FeatureFlagInfo(value = str(toolchain.compiler in _GNU_COMPILERS))]

gnu_compiler_flag = rule(
    implementation = _gnu_compiler_flag_impl,
    attrs = CC_TOOLCHAIN_ATTRS,
    toolchains = use_cc_toolchain(),
    doc = "\"True\" when the C++ toolchain's compiler is GNU-style (mingw-gcc, gcc or clang), \"False\" otherwise.",
)
