#' construct my project "MLRA42_small_area" using rsyncrosim
#' 
#' Non-spatial
#' 3 states: no shrub, low shrub, shrubland
#' single stratum 
#' 
#' EMC 2/9/22

library(dplyr)
library(raster)
library(rsyncrosim)

# connect to syncrosim session
mysession = session('C:/Program Files/SyncroSim')


# ======================
# definitions ----

# create a new library using the session created above
mylibrary = ssimLibrary(name = 'nonspatial_shrubencroachment.ssim',
                        session = mysession,
                        package = 'stsim',
                        overwrite = F)

# open the default project
myproject = project(ssimObject = mylibrary, project = 'Definitions')

# create a new scenario (associated with default project)
myscenario = scenario(ssimObject = myproject, scenario ='My spatial scenario')

# load terminology datasheet
terminology = datasheet(myproject, name='stsim_Terminology')

# change some units
terminology$AmountUnits <- 'Hectares'
terminology$StateLabelX <- 'State'

# save changes
saveDatasheet(myproject, terminology, 'stsim_Terminology')

# change primary stratum (strata tab in Definitions) ----
# open empty stratum datasheet
stratum = datasheet(myproject, 'stsim_Stratum', empty = T)
# add a row
stratum = addRow(stratum, 'Entire Area')
# save it
saveDatasheet(myproject, stratum, 'stsim_Stratum', force=T)

# add values to State Class ----
states = datasheet(myproject, name='stsim_StateLabelX', empty=T)
states = addRow(states, 'NoShrub')
states = addRow(states, 'LowShrub')
states = addRow(states, 'Shrubland')

saveDatasheet(myproject, states, 'stsim_StateLabelX', force=T)

# state label y ----
saveDatasheet(myproject,
              data.frame(Name=c('All')),
              'stsim_StateLabelY',
              force=T)

# state class IDs ----
stateClasses = data.frame(Name = c('NoShrub','LowShrub','Shrubland'))
stateClasses$StateLabelXID = stateClasses$Name
stateClasses$StateLabelYID = 'All'
stateClasses$ID = c(1,2,3)
saveDatasheet(myproject, stateClasses, 'stsim_StateClass', force=T)

# transition types ----
transitiontypes = data.frame(Name = c('Shrub_infilling','Shrub_establishment','Shrub_decline'),
                             ID = c(1,2,3))
saveDatasheet(myproject, transitiontypes, 'stsim_TransitionType', force=T)



# =======================
# scenarios
# ====================

# new scenario
myscenario = scenario(myproject,'Non spatial, best estimates')

# set run control ----
# 6 time steps, 5 iterations, nonspatial
runcontrol = data.frame(MaximumIteration = 5,
                        MinimumTimestep = 0,
                        MaximumTimestep = 6,
                        isSpatial = F)
saveDatasheet(myscenario, runcontrol, 'stsim_RunControl')

# transition probabilities ----

# set deterministic transition paths
dtransitions = datasheet(myscenario, 'stsim_DeterministicTransition', optional=T, empty=T)
# add paths (arrows)
dtransitions = addRow(dtransitions, data.frame(
  StateClassIDSource = 'NoShrub',
  StateClassIDDest = 'NoShrub',
  Location = 'A1'
))
dtransitions = addRow(dtransitions, data.frame(
  StateClassIDSource = 'LowShrub',
  StateClassIDDest = 'LowShrub',
  Location = 'B1'
))
dtransitions = addRow(dtransitions, data.frame(
  StateClassIDSource = 'Shrubland',
  StateClassIDDest = 'Shrubland',
  Location = 'C1'
))
saveDatasheet(myscenario, dtransitions, 'stsim_DeterministicTransition')


# load empty datasheet
ptransitions = datasheet(myscenario, 'stsim_Transition', optional=T, empty=T)

# add row for each transition arrow
ptransitions = addRow(ptransitions, data.frame(
  StateClassIDSource = 'NoShrub',
  StateClassIDDest = 'LowShrub',
  TransitionTypeID = 'Shrub_establishment',
  Probability = 0.445072
))
ptransitions = addRow(ptransitions, data.frame(
  StateClassIDSource = 'LowShrub',
  StateClassIDDest = 'Shrubland',
  TransitionTypeID = 'Shrub_infilling',
  Probability = 0.115768
))
ptransitions = addRow(ptransitions, data.frame(
  StateClassIDSource = 'Shrubland',
  StateClassIDDest = 'LowShrub',
  TransitionTypeID = 'Shrub_decline',
  Probability = 0.235767
))
ptransitions = addRow(ptransitions, data.frame(
  StateClassIDSource = 'LowShrub',
  StateClassIDDest = 'NoShrub',
  TransitionTypeID = 'Shrub_decline',
  Probability = 0.049038
))
saveDatasheet(myscenario, ptransitions, 'stsim_Transition')


# initial conditions ----

# nonspatial
ICNonSpatial = data.frame(TotalAmount = 309692.2,
                          NumCells = 3441025,
                          CalcFromDist = F)
saveDatasheet(myscenario, ICNonSpatial, "stsim_InitialConditionsNonSpatial")

# initial states distribution
ICNonSpatialDistribution = data.frame(StratumID = rep('Entire Area',3),
                                      StateClassID = c('NoShrub','LowShrub','Shrubland'),
                                      RelativeAmount = c(0.4, 60, 39.6))
saveDatasheet(myscenario, ICNonSpatialDistribution, 'stsim_InitialConditionsNonSpatialDistribution')



# output options ----

# create output options: nonspatial
outputOptionsNonSpatial = data.frame(
  SummaryOutputSC = T, SummaryOutputSCTimesteps = 1,
  SummaryOutputTR = T, SummaryOutputTRTimesteps = 1
)
saveDatasheet(myscenario, outputOptionsNonSpatial, 'stsim_OutputOptions')

# =========================
# create another scenario ----

# new scenario will have lower probability of establishment
myscenario_lowestab = scenario(myproject, 
                               scenario = 'Non spatial, low establishment',
                               sourceScenario = myscenario)

# change transition probability
transitions2 = datasheet(myscenario_lowestab,'stsim_Transition')

transitions2$Probability[transitions2$StateClassIDSource=='NoShrub' & transitions2$StateClassIDDest=='LowShrub'] <- 0.2225
# save
saveDatasheet(myscenario_lowestab, transitions2, 'stsim_Transition')

# ===============================
# run scenarios ----

# run both scenarios
myResultScenario = run(myproject, scenario = c('Non spatial, low establishment', 'Non spatial, best estimates'))

# view results ----

# retrieve scenario IDs
# resultIDbestest = subset(myResultScenario,
#                          ParentID==scenarioId(myscenario))$ScenarioID
# resultIDlowestab = subset(myResultScenario,
#                           ParentID==scenarioId(myscenario_lowestab))$ScenarioID

# couldn't get above to work, retrieved by looking at myResultScenario
resultIDbestest = 2
resultIDlowestab = 3

# retrieve output projected state class for both scenarios in tabular form
outputStratumState <- datasheet(
  myproject,
  scenario = c(resultIDbestest, resultIDlowestab),
  name = 'stsim_OutputStratumState'
)

View(outputStratumState)
