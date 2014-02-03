#runApp('C:\\Users\\pbuttigi\\Documents\\Revolution\\EATME\\db-RDA', launch.browser = FALSE)

library(shiny)

## ui.R

# TODO: Add text saying that the data should already be pretreated (e.g. transformed)
shinyUI(
	pageWithSidebar(
		
		# Header defintion
		headerPanel("Perform a (partial) distance-based Redundancy Analysis..."),
		
		# Sidebar defintion
		sidebarPanel(
			tabsetPanel(
			tabPanel("Data upload",
 				
				# Parameters for read.csv...
				checkboxInput('header', 'Header', TRUE),
				
				numericInput(
					inputId = 'rownames',
					value = 1,
					min = 0,
 					label = 'In each file, which column contains row lables (enter "0" if there are no such columns)?'
				),
				
				radioButtons(
					inputId = 'sep',
 					label = 'Separator',
					choices = c(
						Comma = ',',
						Semicolon = ';',
						Tab = '\t'
					)
				),
				
				radioButtons(
					inputId = 'quote',
					label = 'Quote',
					choices = c(
						'Double quotes' = '"',
						'Single quotes' = "'",
						'None' = ''
					)
				)
			), # End CSV parameter UI
				
				# File Upload UI
				fileInput(
					inputId = 'dataset', 
					label = 'Select a CSV file with a table of objects (sites, samples, etc) as rows and response variables as columns.',
					accept = c('text/csv','text/comma-separated-values','.csv')
				),
				
				
				fileInput(
					'explanatoryVars', 
					'Select a CSV file with a table of objects (sites, samples, etc) as rows and explanatory variables as columns. Factor levels should have at least one non-numeric character. Numeric variables should have values that are solely numbers with no whitespace. Note: all columns will be used as contraints!',
					accept = c('text/csv','text/comma-separated-values','.csv')
				),
				
				fileInput(
					'conditioningVars', 
					'Select a CSV file with a table of objects (sites, samples, etc) as rows and conditioning variables as columns. Factor levels should have at least one non-numeric character. Numeric variables should have values that are solely numbers with no whitespace.',
					accept = c('text/csv','text/comma-separated-values','.csv')
				),
				
				# Select the conditioning variables of interest...
				
				htmlOutput("whichCondVarsUI"),
				
				fileInput(
					'strata', 
					'If your objects are stratified (e.g. nested), select the CSV file which specifes which rows belong to each stratum. Strata should be represented by integers.',
					accept = c('text/csv','text/comma-separated-values','.csv')
				),
				
				# End file upload UI
				
				
			
			# Only show this panel if the 
   tabPanel(
      "Data transformations",
					
			# Should the data be transformed? Input for decostand()
			radioButtons(
				inputId = 'transform',
				label = 'If needed, select a transformation for your response data...',
				choices = c(
					'No transformation' = 'none',
					'Z score' = 'standardize',
					'Chi square' = 'chi.square',
					'Hellinger' = 'hellinger'
					)
				),

			# Scale variables to unit variance?
			checkboxInput('scaleVars', 'Would you like to scale your response variables to unit variance?', FALSE),

			
			# Should the explanatory data be transformed? Input for decostand()
			radioButtons(
				inputId = 'expTransform',
				label = 'If needed, select a transformation for your explanatory variables...',
				choices = c(
					'No transformation' = 'none',
					'Z score' = 'standardize',
					'Chi square' = 'chi.square',
					'Hellinger' = 'hellinger'
					)
				),
			
			# Should the conditioning variables be transformed? Input for decostand()
			radioButtons(
				inputId = 'condTransform',
				label = 'If needed, select a transformation for your conditioning variables...',
				choices = c(
					'No transformation' = 'none',
					'Z score' = 'standardize',
					'Chi square' = 'chi.square',
					'Hellinger' = 'hellinger'
					)
				)
			
		),

	tabPanel(
      "PCoA parameters...",
			# Parameters for metaMDS...
			# Select dissimilarity measure
			radioButtons(
				inputId = 'dissim',
				label = 'Select a dissimilarity measure',
				choices = c(
					'Euclidean' = 'euclidean',
					'Bray-Curtis' = 'bray',
					'Jaccard (presence/absence data)' = 'jaccard' # This will set presAbs to TRUE
					)
				),
			
			# Presence absence or abundance?
			radioButtons(
				inputId = 'presAbs',
				label = 'Do you have abundance (or other count data) or presence absence data?',
				choices = c(
					'Abundance' = 'FALSE',
					'Presence / Absence' = 'TRUE'
				)
			),
			
			# Correction method 2 for negative eigenvalues
			radioButtons(
				inputId = 'correctionMethod2',
				label = 'Should negative eigenvalues be corrected by the addition of a constant to non-diagonal dissimilarities?',
				choices = c(
					'Yes' = TRUE,
					'No' = FALSE
				)
			),
			
			# metaMDSdist autoscaling
			radioButtons(
				inputId = 'autoTransform',
				label = 'Should a flexible shortest path data transformation be attempted? This may help estimate dissimilarities between sites with no variables in common, but should be used with caution.',
				choices = c(
					'No'  = FALSE,
					'Yes' = TRUE
				)
			),
			
			# Type of scaling to use...
			radioButtons(
				inputId = 'scaling',
				label = 'Would you like Type I or Type II scaling used in your biplot?',
				choices = c(
					'Type I' = 1,
					'Type II' = 2
				)
			),
			
			# Label points?
			radioButtons(
				inputId = 'labels',
				label = 'Would you like points to be labeled?',
				choices = c(
					'Yes' = "text",
					'No' = "points"
				)
			),
			
	
			# Objects, variables, or both?
			radioButtons(
				inputId = 'display',
				label = 'Would you like to plot the objects, the response variables, or both?',
				choices = c(
					'both' = "both",
					'objects' = "sites",
					'variables' = "species"
				)
			)
		),
		
		# Download panel
		tabPanel(
			"Download results...",
			downloadButton('downloadData.dissMat', 'Download dissimilarity matrix...'),
			br(),
			downloadButton('downloadData.plot', 'Download ordination...'),
			br(),
			downloadButton('downloadData.objectCoordinates', 'Download object coordinates...'),			
			br(),
			downloadButton('downloadData.variableCoordinates', 'Download variable coordinates...')	
			)
		)
	),
			# Main panel defintion
			# TODO: Use tabPanels for plots and numeric result output
			# See if conditionalPanel works for relevant parameters
			mainPanel(
				tabsetPanel(
					tabPanel("Plot", plotOutput("plot")),
					tabPanel("Summary", verbatimTextOutput("print")),
					tabPanel("ANOVA test of significance", verbatimTextOutput("printSig"))
					)
				)

			)
		)
	#)