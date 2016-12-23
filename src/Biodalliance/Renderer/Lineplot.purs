module Biodalliance.Renderer.Lineplot
       ( renderTier
       , drawTier
       ) where

import Prelude

import Control.Monad.Eff (Eff)
import Data.Array (tail, zipWith)
import Data.Function.Uncurried (Fn1, Fn2, mkFn1, mkFn2, runFn1)
import Data.Maybe (Maybe(..))
import Graphics.Canvas (CANVAS, setStrokeStyle)

import Biodalliance.Glyph (Glyph, line, flattenGlyphs, linearScale)
import Biodalliance.Track (Tier, Feature)
import Biodalliance.Track as Track


type LineFeature = Feature (score :: Number)

type LinePlotConfig = { minScore :: Number
                      , maxScore :: Number
                      , canvasHeight :: Number
                      , color :: String
                      }

normalizeScore :: LinePlotConfig -> Number -> Number
normalizeScore conf y = ((y - conf.minScore) / (conf.maxScore))

linePlotGlyph :: forall eff. LinePlotConfig -> Tier -> Glyph Unit eff
linePlotGlyph conf tier = flattenGlyphs gs
  where fToPoint f = { x: f.min, y: normalizeScore conf f.score }
        gs = case tail (Track.features tier) of
          Nothing -> []
          Just fs' -> zipWith (\f1 f2 -> line (fToPoint f1) (fToPoint f2))
                      (Track.features tier) fs'


drawLinePlot :: forall eff. LinePlotConfig -> Tier -> Eff (canvas :: CANVAS | eff) Unit
drawLinePlot conf tier = do
  pure $ Track.setHeight tier conf.canvasHeight
  let sf = Track.scaleFactor tier linearScale
      ctx = Track.canvasContext tier
  setStrokeStyle conf.color ctx
  linePlotGlyph conf tier sf ctx


qtlPlotConfig :: LinePlotConfig
qtlPlotConfig = { minScore: 3.0
                , maxScore: 5.0
                , canvasHeight: 400.0
                , color: "#dd0000"}

renderTier :: forall eff. Fn2 String Tier (Eff (canvas :: CANVAS | eff) Unit)
renderTier = mkFn2 \status tier -> Track.runEff $ runFn1 drawTier tier

drawTier :: forall eff. Fn1 Tier (Eff (canvas :: CANVAS | eff) Unit)
drawTier = mkFn1 (drawLinePlot qtlPlotConfig)
