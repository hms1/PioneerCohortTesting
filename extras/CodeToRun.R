# Make sure to install all dependencies (not needed if already done) -------------------------------

# Prevents errors due to packages being built for other R versions: 
#Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = TRUE)

# First, it probably is best to make sure you are up-to-date on all existing packages. 
# Important: This code is best run in R, not RStudio, as RStudio may have some libraries 
# (like 'rlang') in use.
#update.packages(ask = "graphics")

# Running the package -------------------------------------------------------------------------------
#devtools::install_local("PioneerTestCohorts/",force=T)
library(PioneerTestCohorts)

# Optional: specify where the temporary files (used by the ff package) will be created:
options(fftempdir = "~/tmp")

# Details for connecting to the server:
connectionDetails <- createConnectionDetails(dbms = "redshift",
                                             server = paste0(Sys.getenv("FRANCE_SERVER"),"/prod_dafr"),
                                             user = Sys.getenv("REDSHIFT_USER"),
                                             password = Sys.getenv("REDSHIFT_PASSWORD"),
                                             port = 5439)

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

# Details specific to the database:
outputFolder <- "~/pioneer_testing/output_france_2" # Be sure to have one outputFolder per database!
cdmDatabaseSchema <- Sys.getenv("FRANCE_SCHEMA") 
cohortDatabaseSchema <- "study_reference" ## a schema where you can write tables

cohortTable <- "pioneer_testing_2" ## table name to write cohrots to
databaseId <- "DAFR" 
databaseName <- "DA FRANCE"
databaseDescription <- "DA FRANCE"

# Selecting the cohort groups to run:
cohortGroups <- c("Testing") # Prioritizing outcomes for now

# Use this to run the evaluations. The results will be stored in a zip file called 
# 'AllResults_<databaseId>.zip in the outputFolder. 
execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = cohortDatabaseSchema,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        cohortGroups = cohortGroups,
        createCohorts = TRUE,
        runCohortDiagnostics = TRUE,
        minCellCount = 5) 

CohortDiagnostics::preMergeDiagnosticsFiles(file.path(outputFolder, "Testing/Export"))

# Use this to view the results. Multiple zip files can be in the same folder. If the files were pre-merged, this is automatically detected: 
CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, "Testing/Export"))
