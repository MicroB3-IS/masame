#runApp('C:\\Users\\pbuttigi\\Documents\\Revolution\\EATME\\NMDS', launch.browser = FALSE)

library(shiny)

## ui.R

# TODO: Add text saying that the data should already be pretreated (e.g. transformed)
shinyUI(
	pageWithSidebar(
		
		# Header defintion
		headerPanel("Perform an NMDS analysis..."),
		
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
			
			
			tabPanel(
				"NMDS parameters...",
				# Parameters for metaMDS...
				# Select dissimilarity measure
				radioButtons(
					inputId = 'dissim',
					label = 'Select a dissimilarity measure. Note, the Jaccard measure is only valid for presence absence data.',
					choices = c(
						'Euclidean' = 'euclidean',
						'Bray-Curtis' = 'bray',
						'Jaccard (presence/absence data)' = 'jaccard' # This will set presAbs to TRUE
						)
				),
			
				# Presence absence or abundance?
				radioButtons(
					inputId = 'presAbs',
					label = 'Do you have abundance (or other count data) or presence/absence data?',
					choices = c(
						# Logicals fed into 'binary = ' arg of vegdist()
						'Abundance' = 'FALSE', 
						'Presence / Absence' = 'TRUE'
						)
					),
			
				# Number of dimensions to allow.
				# In addition to changing the parameters of metaMDS(), this option
				# will trigger either a single plot (dimNum = 2) or a multi-
				# panel plot (dimNum = 3) as graphical output.
				radioButtons(
					inputId = 'dimNum',
					label = 'How many dimensions should the solution have?',
					choices = c(
						'Two' = 2,
						'Three' = 3
						)
				),
			
			# Label points?
			checkboxInput('labels', 'Label points?', FALSE)
			),
		
			# Download panel
			tabPanel(
				"Download results...",
				downloadButton('downloadData.dissMat', 'Download dissimilarity matrix...'),
				br(),
				downloadButton('downloadData.plot', 'Download ordination...'),
				br(),
				downloadButton('downloadData.stressplot', 'Download stress plot...'),
				br(),
				downloadButton('downloadData.objectCoordinates', 'Download object coordinates...')			
			)
		) # End tabSetPanel()
		), # End sideBarPanel()

			# Main panel defintion
			# TODO: Use tabPanels for plots and numeric result output
			# See if conditionalPanel works for relevant parameters
			mainPanel(
				tabsetPanel(
					tabPanel("Plot", plotOutput("plot")),
					tabPanel("Shepard stress plot", plotOutput("stressplot")),
					tabPanel("Summary", verbatimTextOutput("print"))#,
					#tabPanel("Table", tableOutput("table")
					)
			) # End mainPanel()

	) # End pageWithSidebar()
) # End shinyUI()