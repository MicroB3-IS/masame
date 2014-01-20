#runApp('C:\\Users\\pbuttigi\\Documents\\Revolution\\EATME\\db-RDA', launch.browser = FALSE)

library(shiny)
library(vegan)

shinyServer(function(input, output){
	
# Handle uploaded response data...
	datasetInput <- reactive({		
		input$dataset
	})

	datasetFile <- reactive({
		inFile <- datasetInput()
	
		if (is.null(inFile))
				return(NULL)
				
		read.csv(
			file = inFile$datapath,
			header = input$header,
			sep = input$sep,
			quote = input$quote,
			row.names = if(input$rownames == 0){NULL} else{input$rownames}
			)	
	})

# Handle uploaded explanatory data...
	explanatoryInput <- reactive({		
		input$explanatoryVars
	})

	explanatoryFile <- reactive({
		exFile <- explanatoryInput()
	
		if (is.null(exFile))
				return(NULL)
				
		read.csv(
			file = exFile$datapath,
			header = input$header,
			sep = input$sep,
			quote = input$quote,
			row.names = if(input$rownames == 0){NULL} else{input$rownames}
			)	
	})

# Handle uploaded strata data...
	strataInput <- reactive({		
		input$strata
	})

	strataFile <- reactive({
		strFile <- strataInput()
	
		if (is.null(strFile))
				return(NULL)
				
		read.csv(
			file = strFile$datapath,
			header = input$header,
			sep = input$sep,
			quote = input$quote,
			row.names = if(input$rownames == 0){NULL} else{input$rownames}
			)	
	})

	
# Use metaMDSdist if stepacross transformation is to be used, just vegdist
# otherwise
	
	# TODO: Priority: high
 	# Odd behaviour at times, seems not to react to changes in 
	# input$autoTransform occasionally. Could be a machine-specific 
	# issue.
			dissMat <- reactive({
				if (input$autoTransform == TRUE){
					metaMDSdist(
						datasetFile(),
						distance = input$dissim # vegdist is used here
						)
					} else {
							vegdist(
								datasetFile(),
								method = input$dissim,
								binary = ifelse(input$dissim == 'jaccard', TRUE, input$presAbs)
								)
						
					}
			})

# TODO: Priority: nice to have
# Add textInput to ui allowing users to select columns of the explanatoryFile

# TODO: Priortiy: important
# capscale() does not perform constraint aliasing when running in the App, but
# does this when running the R console. This changes the output! Must figure out why...
	dbrda <- reactive({ 
		capscale(
			dissMat() ~ .,
			data = explanatoryFile(),
			comm = datasetFile(),
			add = input$correctionMethod2
			
		)
	})

# Test significance of model
anova <- reactive({
	if(is.null(strataFile())){
 			anova.cca(
				dbrda()
				)
	} else {
 			anova.cca(
				dbrda(),
				strata = strataFile()
				)
		}
	})


# Prepare output

	output$plot <- renderPlot({
		
		if (input$display == "both") {
		ordiplot(
			dbrda(),
 			type = input$labels,
			scaling = as.numeric(input$scaling),
			col = c("red", "blue")
			)
		} else {
		ordiplot(
			dbrda(),
 			type = input$labels,
			scaling = as.numeric(input$scaling),
			col = c("red", "blue"),
			display = input$display
			)	
		}
	})


	output$print <- renderPrint({
		print(summary(dbrda()))
		})

	output$printSig <- renderPrint({
		print(anova())
		print(dim(strataFile()))
		})


# Prepare downloads

	output$downloadData.plot <- downloadHandler(
	  filename <- function() {
		paste('dbRDA_plot-', Sys.Date(), '.tiff', sep='')
	  },
	  content <- function(file) {
		tiff(
			file,
			width = 2000,
			height = 2000,
			units = "px",
			pointsize = 12,
			res = 300
			)
			
		ordiplot(
			dbrda(),
 			type = input$labels,
			scaling = as.numeric(input$scaling),
			col = c("red", "blue"),
			)
			
		dev.off()
	  },
	  contentType = 'image/png'
	)

# Download dissimilarity matrix
	output$downloadData.dissMat <- downloadHandler(
	  filename <- function() {
		paste('Dissimilarity_matrix-', Sys.Date(), '.csv', sep='')
	  },
	  content <- function(file) {
		write.csv(as.matrix(dissMat()), file)
	  },
	  contentType = 'text/csv'
	)

# Download object coordinates
	output$downloadData.objectCoordinates <- downloadHandler(
	  filename <- function() {
		paste('Object_coordinates-', Sys.Date(), '.csv', sep='')
	  },
	  content <- function(file) {
		write.csv(dbrda()$CA$u, file)
	  },
	  contentType = 'text/csv'
	)

# Download variable coordinates
output$downloadData.variableCoordinates <- downloadHandler(
	  filename <- function() {
		paste('Variable_coordinates-', Sys.Date(), '.csv', sep='')
	  },
	  content <- function(file) {
		write.csv(dbrda()$CA$v, file)
	  },
	  contentType = 'text/csv'
	)
		
	})