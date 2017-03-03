module Biodalliance.Glyph.Free.Position
       ( glyphToGlyphPosition )
       where

import Prelude
import Math as Math
import Biodalliance.Glyph.Free (GlyphF(..), Glyph)
import Biodalliance.Glyph.Position (GlyphPosition(GlyphPos))
import Biodalliance.Types (Point)
import Control.Monad.Free (foldFree)
import Control.Monad.RWS (tell)
import Control.Monad.Writer (Writer, execWriter)
import Data.Traversable (traverse_)


rectanglePos :: Point -> Point -> GlyphPosition
rectanglePos p1 p2 = GlyphPos ({ min: Math.min p1.x p2.x
                               , max: Math.max p1.x p2.x
                               , minY: Math.min p1.y p2.y
                               , maxY: Math.max p1.y p2.y
                               })

pointPos :: Point -> GlyphPosition
pointPos p = GlyphPos ({ min: Math.min p.x p.x
                       , max: Math.max p.x p.x
                       , minY: Math.min p.y p.y
                       , maxY: Math.max p.y p.y
                       })

glyphPosN :: GlyphF ~> Writer GlyphPosition
glyphPosN (Stroke _ a) = pure a
glyphPosN (Fill _ a) = pure a
glyphPosN (Circle p r a) = do
  tell (GlyphPos { min: p.x - (r * 1.5)
                 , max: p.x + (r * 1.5)
                 , minY: p.y - (r * 1.5)
                 , maxY: p.y + (r * 1.5)
                 })
  pure a
glyphPosN (Line p1 p2 a) = do
  tell (rectanglePos p1 p2)
  pure a
glyphPosN (Rect p1 p2 a) = do
  tell (rectanglePos p1 p2)
  pure a
glyphPosN (Path ps a) = do
  traverse_ (tell <<< pointPos) ps
  pure a


glyphToGlyphPosition :: ∀ a. Glyph a -> GlyphPosition
glyphToGlyphPosition = execWriter <<< foldFree glyphPosN
