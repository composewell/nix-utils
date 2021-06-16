# Try to find attributes directly under a given attribute path in
# <nixpkgs>. This can be useful if you want to know what all functions
# are available.
#
# Invoke like this:
# $ nix-instantiate -E '(import ./print-nix-functions.nix).listAll (import <nixpkgs> {})' 2>&1|less
# $ nix-instantiate -E '(import ./print-nix-functions.nix).listAll (import <nixpkgs> {}).lib' 2>&1|less
# $ nix-instantiate -E '(import ./print-nix-functions.nix).listAll (import <nixpkgs> {}).haskellPackages' 2>&1|less
#
# Functions:
#
# listAll: list all attributes in a set arg
# listFns: list all functions or functor set type attributes in a set arg
# listDrvs: list all non-functor derivation type attributes in a set arg
# listNoFnNoDrv: list all set type attributes that are neither functors nor derivations
# listOthers: list all set type attributes that are not derivations
#
# Each function has three flavors:
#
# listAll: list all attributes in a set
# listAllTop: list all attrs in <nixpkgs>
# listAllChild: list all attrs of a child of <nixpkgs>
#
rec {
    # XXX TODO If the child attribute is "x.y.z" then evaluate .x and then
    # .y and then .z.

  # This we can do much faster in the nix repl

  # List all the attribute names in a set
  listAll = entity:
      let nixpkgs = import <nixpkgs> {};
          lib = nixpkgs.lib;
          tryEval = builtins.tryEval;
          # Avoid things that are undefined or cannot be evaluated
          isEval = name: v:
              let res = tryEval (builtins.typeOf v);
              # Note that we need "!= false", "== true" won't work.
              in if res.value != false then true else false;
          funcAttrs = lib.attrsets.filterAttrs isEval entity;
          attrs = builtins.attrNames funcAttrs;
      in lib.debug.traceSeq (lib.strings.concatStringsSep "\n" attrs) "";

  # This we can do much faster in the nix repl
  listAllTop =
      let nixpkgs = import <nixpkgs> {};
      in listAll nixpkgs;

  # This we can do much faster in the nix repl
  listAllChild = child:
      let nixpkgs = import <nixpkgs> {};
      in listAll (builtins.getAttr child nixpkgs);

  # List attributes of an entity that are functions or functors
  listFns = entity:
      let nixpkgs = import <nixpkgs> {};
          lib = nixpkgs.lib;
          tryEval = builtins.tryEval;
          isFunc = name: v:
              let res = tryEval (builtins.isFunction v || v ? "__functor");
              in res.value;
          funcAttrs = lib.attrsets.filterAttrs isFunc entity;
          attrs = builtins.attrNames funcAttrs;
      in lib.debug.traceSeq (lib.strings.concatStringsSep "\n" attrs) "";

  listFnsTop =
      let nixpkgs = import <nixpkgs> {};
      in listFns nixpkgs;

  listFnsChild = child:
      let nixpkgs = import <nixpkgs> {};
      in listFns (builtins.getAttr child nixpkgs);

  # list attributes of an entity that are non-functor derivations
  listDrvs = entity:
      let nixpkgs = import <nixpkgs> {};
          lib = nixpkgs.lib;
          tryEval = builtins.tryEval;
          isSet = name: v:
              let res = tryEval (builtins.isAttrs v && ! (v ? "__functor") && (builtins.hasAttr "type" v && v.type == "derivation"));
              in res.value;
          setAttrs = lib.attrsets.filterAttrs isSet entity;
          attrs = builtins.attrNames setAttrs;
      in lib.debug.traceSeq (lib.strings.concatStringsSep "\n" attrs) "";

  listDrvsTop =
      let nixpkgs = import <nixpkgs> {};
      in listDrvs nixpkgs;

  listDrvsChild = child:
      let nixpkgs = import <nixpkgs> {};
      in listDrvs (builtins.getAttr child nixpkgs);

  # list attrs of an enitiy that are non-functor sets, and not derivations
  listNoFnNoDrv = entity:
      let nixpkgs = import <nixpkgs> {};
          lib = nixpkgs.lib;
          tryEval = builtins.tryEval;
          isSet = name: v:
              let res = tryEval (builtins.isAttrs v && ! (v ? "__functor") && !(builtins.hasAttr "type" v && v.type == "derivation"));
              in res.value;
          setAttrs = lib.attrsets.filterAttrs isSet entity;
          attrs = builtins.attrNames setAttrs;
      in lib.debug.traceSeq (lib.strings.concatStringsSep "\n" attrs) "";

  listNoFnNoDrvTop =
      let nixpkgs = import <nixpkgs> {};
      in listNoFnNoDrv nixpkgs;

  listNoFnNoDrvChild = child:
      let nixpkgs = import <nixpkgs> {};
      in listNoFnNoDrv (builtins.getAttr child nixpkgs);

  # list attrs of an entitiy that are non-set non-functions
  listOthers = entity:
      let nixpkgs = import <nixpkgs> {};
          lib = nixpkgs.lib;
          tryEval = builtins.tryEval;
          isSet = name: v:
              let res = tryEval (!builtins.isFunction v && !builtins.isAttrs v);
              in res.value;
          setAttrs = lib.attrsets.filterAttrs isSet entity;
          attrs = builtins.attrNames setAttrs;
      in lib.debug.traceSeq (lib.strings.concatStringsSep "\n" attrs) "";

  listOthersTop =
      let nixpkgs = import <nixpkgs> {};
      in listOthers nixpkgs;

  listOthersChild = child:
      let nixpkgs = import <nixpkgs> {};
      in listOthers (builtins.getAttr child nixpkgs);
}
