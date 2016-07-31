{-
(c) The University of Glasgow 2006
(c) The AQUA Project, Glasgow University, 1993-1998

\section[TcAnnotations]{Typechecking annotations}
-}

{-# LANGUAGE CPP #-}

module GHCVM.TypeCheck.TcAnnotations ( tcAnnotations, annCtxt ) where

-- TODO: #ifdef GHCI
-- import {-# SOURCE #-} TcSplice ( runAnnotation )
-- import GHCVM.BasicTypes.Module
-- import GHCVM.Main.DynFlags
-- import Control.Monad ( when )
-- #endif

import GHCVM.HsSyn.HsSyn
import GHCVM.Main.Annotations
import GHCVM.BasicTypes.Name
import GHCVM.TypeCheck.TcRnMonad
import GHCVM.BasicTypes.SrcLoc
import GHCVM.Utils.Outputable

import GHCVM.Utils.FastString

-- #ifndef GHCI

tcAnnotations :: [LAnnDecl Name] -> TcM [Annotation]
-- No GHCI; emit a warning (not an error) and ignore. cf Trac #4268
tcAnnotations [] = return []
tcAnnotations anns@(L loc _ : _)
  = do { setSrcSpan loc $ addWarnTc $
             (ptext (sLit "Ignoring ANN annotation") <> plural anns <> comma
             <+> ptext (sLit "because this is a stage-1 compiler or doesn't support GHCi"))
       ; return [] }

-- #else

-- tcAnnotations :: [LAnnDecl Name] -> TcM [Annotation]
-- -- GHCI exists, typecheck the annotations
-- tcAnnotations anns = mapM tcAnnotation anns

-- tcAnnotation :: LAnnDecl Name -> TcM Annotation
-- tcAnnotation (L loc ann@(HsAnnotation _ provenance expr)) = do
--     -- Work out what the full target of this annotation was
--     mod <- getModule
--     let target = annProvenanceToTarget mod provenance

--     -- Run that annotation and construct the full Annotation data structure
--     setSrcSpan loc $ addErrCtxt (annCtxt ann) $ do
--       -- See #10826 -- Annotations allow one to bypass Safe Haskell.
--       dflags <- getDynFlags
--       when (safeLanguageOn dflags) $ failWithTc safeHsErr
--       runAnnotation target expr
--     where
--       safeHsErr = vcat [ ptext (sLit "Annotations are not compatible with Safe Haskell.")
--                   , ptext (sLit "See https://ghc.haskell.org/trac/ghc/ticket/10826") ]

-- annProvenanceToTarget :: Module -> AnnProvenance Name -> AnnTarget Name
-- annProvenanceToTarget _   (ValueAnnProvenance (L _ name)) = NamedTarget name
-- annProvenanceToTarget _   (TypeAnnProvenance (L _ name))  = NamedTarget name
-- annProvenanceToTarget mod ModuleAnnProvenance             = ModuleTarget mod
-- #endif

annCtxt :: OutputableBndr id => AnnDecl id -> SDoc
annCtxt ann
  = hang (ptext (sLit "In the annotation:")) 2 (ppr ann)
