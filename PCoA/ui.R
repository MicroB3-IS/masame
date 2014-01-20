library(shiny)

## ui.R

# TODO: Add text saying that the data should already be pretreated (e.g. transformed)
shinyUI(
	pageWithSidebar(
		
		# Header defintion
		headerPanel("Perform a Principal Coordinates Analysis..."),
		
		# Sidebar defintion
		sidebarPanel(
			tabsetPanel(
			tabPanel("Data upload", 
				fileInput(
					inputId = 'dataset', 
					label = 'Select a CSV file to upload for analysis...',
					accept = c('text/csv','text/comma-separated-values','.csv')
					),
				
				# TODO: See how this can be done
				#fileInput(
					#'metadata', 
					#'If you would like to use additional data for modifying your plot (e.g. colouring points) upload a single column CSV file here...',
					#accept = c('text/csv','text/comma-separated-values','.csv')
					#),
				
				# Parameters for read.csv...
				checkboxInput('header', 'Header', TRUE),
				
				numericInput(
					inputId = 'rownames',
					value = 1,
					min = 0,
 					label = 'Which column contains row lables (enter "0" if there is no such column)?'
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
				),
			
			# Only show this panel if the 
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
			
			# Label points?
			checkboxInput('labels', 'Label points?', FALSE)
			),
		
		# Download panel
		tabPanel(
			"Download results...",
			downloadButton('downloadData.dissMat', 'Download dissimilarity matrix...'),
			downloadButton('downloadData.plot', 'Download ordination...'),
			downloadButton('downloadData.objectCoordinates', 'Download object coordinates...'),			
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
					tabPanel("Summary", verbatimTextOutput("print"))#,
					#tabPanel("Table", tableOutput("table")
					)
				)

			)
		)
	#)