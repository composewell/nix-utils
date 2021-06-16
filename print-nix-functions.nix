rec {
    # XXX TODO If the child attribute is "x.y.z" then evaluate .x and then
    # .y and then .z.

  # This we can do much faster in the nix repl
  listAll = entity:
      let nixpkgs = import <nixpkgs> {};
          lib = nixpkgs.lib;
          tryEval = builtins.tryEval;
          isEval = name: v:
              let res = tryEval (builtins.typeOf v);
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

  listSets = entity:
      let nixpkgs = import <nixpkgs> {};
          lib = nixpkgs.lib;
          tryEval = builtins.tryEval;
          isSet = name: v:
              let res = tryEval (builtins.isAttrs v && ! (v ? "__functor") && (builtins.hasAttr "type" v && v.type == "derivation"));
              in res.value;
          setAttrs = lib.attrsets.filterAttrs isSet entity;
          attrs = builtins.attrNames setAttrs;
      in lib.debug.traceSeq (lib.strings.concatStringsSep "\n" attrs) "";

  listSetsTop =
      let nixpkgs = import <nixpkgs> {};
      in listSets nixpkgs;

  listSetsChild = child:
      let nixpkgs = import <nixpkgs> {};
      in listSets (builtins.getAttr child nixpkgs);

  listNoDrvSets = entity:
      let nixpkgs = import <nixpkgs> {};
          lib = nixpkgs.lib;
          tryEval = builtins.tryEval;
          isSet = name: v:
              let res = tryEval (builtins.isAttrs v && ! (v ? "__functor") && !(builtins.hasAttr "type" v && v.type == "derivation"));
              in res.value;
          setAttrs = lib.attrsets.filterAttrs isSet entity;
          attrs = builtins.attrNames setAttrs;
      in lib.debug.traceSeq (lib.strings.concatStringsSep "\n" attrs) "";

  listNoDrvSetsTop =
      let nixpkgs = import <nixpkgs> {};
      in listNoDrvSets nixpkgs;

  listNoDrvSetsChild = child:
      let nixpkgs = import <nixpkgs> {};
      in listNoDrvSets (builtins.getAttr child nixpkgs);

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
