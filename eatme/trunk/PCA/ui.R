library(shiny)

## ui.R

# TODO: Add text saying that the data should already be pretreated (e.g. transformed)
shinyUI(
	pageWithSidebar(
		
		# Header defintion
		headerPanel("Perform a Principal Components Analysis..."),
		
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
      "PCA parameters...",
			# Parameters for PCA...
			
			# Should the data be transformed? Input for decostand()
			radioButtons(
				inputId = 'transform',
				label = 'Select a transformation if needed...',
				choices = c(
					'No transformation' = 'none',
					'Z score' = 'standardize',
					'Chi square' = 'chi.square',
					'Hellinger' = 'hellinger'
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
				)
			
			),
		
		tabPanel(
			"Download results...",
			downloadButton('downloadData.plot', 'Download plot...'),
			downloadButton('downloadData.objectScores', 'Download object scores...'),
			downloadButton('downloadData.variableScores', 'Download variable scores...')
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
					tabPanel("Eigenvalues", verbatimTextOutput("eigenvals")),
					tabPanel("Object scores", verbatimTextOutput("objectScores")),
					tabPanel("Variable scores", verbatimTextOutput("variableScores"))#,
					#tabPanel("Table", tableOutput("table")
					)
				)

			)
		)
	#)