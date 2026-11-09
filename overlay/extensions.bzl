"""Bzlmod extension letting the root module provide OpenSSL's native dependencies."""

DEPENDENCIES_REPOSITORY = "openssl_deps"

_DEFAULTS = {
    "zlib": Label("//bazel:no_zlib"),
}

def _openssl_deps_repository_impl(repository_ctx):
    repository_ctx.file("BUILD.bazel", "\n".join([
        """alias(
    name = "{name}",
    actual = "{actual}",
    visibility = ["//visibility:public"],
)
""".format(name = name, actual = actual)
        for name, actual in sorted(repository_ctx.attr.dependencies.items())
    ]))

_openssl_deps_repository = repository_rule(
    implementation = _openssl_deps_repository_impl,
    attrs = {
        "dependencies": attr.string_dict(
            mandatory = True,
            doc = "Dependency name to the label it aliases.",
        ),
    },
)

def _openssl_impl(module_ctx):
    dependencies = {name: str(default) for name, default in _DEFAULTS.items()}
    for module in module_ctx.modules:
        for index, tag in enumerate(module.tags.dependencies):
            if not module.is_root:
                fail("openssl.dependencies() may only be used by the root module, not {!r}".format(module.name))
            if index > 0:
                fail("openssl.dependencies() may only be used once")
            for name in _DEFAULTS:
                label = getattr(tag, name)
                if label:
                    dependencies[name] = str(label)

    _openssl_deps_repository(
        name = DEPENDENCIES_REPOSITORY,
        dependencies = dependencies,
    )
    return module_ctx.extension_metadata(reproducible = True)

_dependencies = tag_class(
    attrs = {
        "zlib": attr.label(
            doc = "cc_library providing zlib.h and zconf.h. Only used on platforms generated with zlib " +
                  "enabled; zlib-dynamic only needs the headers.",
        ),
    },
    doc = "Replaces the native libraries OpenSSL compiles against. Root module only.",
)

openssl = module_extension(
    implementation = _openssl_impl,
    tag_classes = {
        "dependencies": _dependencies,
    },
)
