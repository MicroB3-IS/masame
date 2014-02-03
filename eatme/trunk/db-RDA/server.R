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

# Handle uploaded conditioning variables...
	conditioningInput <- reactive({		
		input$conditioningVars
	})

	conditioningFile <- reactive({
		conFile <- conditioningInput()
	
		if (is.null(conFile))
				return(NULL)
				
		read.csv(
			file = conFile$datapath,
			header = input$header,
			sep = input$sep,
			quote = input$quote,
			row.names = if(input$rownames == 0){NULL} else{input$rownames}
			)	
	})

# Generate UI element to select which conditioning variables should be used...
		output$whichCondVarsUI <- renderUI({
			if (is.null(conditioningFile()))
					return()
					
				checkboxGroupInput(
					inputId = "whichCondVars", 
					label = "Select at least one of your conditioning variables to perform a partial analysis:",
					choices = names(conditioningFile()),
					selected = names(conditioningFile())
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

# Transform data if requested...
	transData <- reactive({
		
		if(is.null(input$dataset))
			return()
			
		if(
			!is.numeric(as.matrix(datasetFile())) &
 			input$transform != 'none'
		)
			stop("Non-numeric values detected! Transformation invalid.")
	
		if (input$transform == 'none' | is.null(input$transform)){
			transData <- datasetFile()
		} else {
			decostand(
				datasetFile(),
				method = input$transform,
			)
		}
			
	})

# Transform explanatory data if requested...
	transExpData <- reactive({
		
		if(is.null(input$explanatoryVars))
			return()
		
		if(
			!is.numeric(as.matrix(exFile())) &
 			input$expTransform != 'none'
		)
			stop("Non-numeric values detected! Transformation invalid.")
	
	
		if (input$expTransform == 'none' | is.null(input$expTransform)){
			transExpData <- explanatoryFile()
		} else {
			decostand(
				explanatoryFile(),
				method = input$expTransform,
			)
		}
			
	})

# Transform conditioning data if requested...
	transCondData <- reactive({
		
		if(is.null(input$conditioningVars))
			return()
	
		if (input$condTransform == 'none' | is.null(input$condTransform)){
			transCondData <- conditioningFile()
		} else {
			decostand(
				conditioningFile(),
				method = input$condTransform,
			)
		}
			
	})
	
# Use metaMDSdist if stepacross transformation is to be used, just vegdist
# otherwise

			dissMat <- reactive({
				
				if(is.null(input$dataset))
					return()
				
				if (input$autoTransform == TRUE){
					metaMDSdist(
						transData(),
						distance = input$dissim # vegdist is used here
						)
					} else {
							vegdist(
								transData(),
								method = input$dissim,
								binary = ifelse(input$dissim == 'jaccard', TRUE, input$presAbs)
								)
						
					}
			})

# TODO: Priortiy: important
# capscale() does not perform constraint aliasing when running in the App, but
# does this when running the R console. This changes the output! Must figure out why...

	dbrda <- reactive({ 
		
		if (is.null(input$dataset) | is.null(input$explanatoryVars))
					return()
		
		if 	(is.null(input$conditioningVars)){	
			
			capscale(
				dissMat() ~ .,
				data = transExpData(),
				comm = transData(),
				add = input$correctionMethod2
				
			)
		} else if (!is.null(input$conditioningVars)){
			
			capscale(
				formula = as.formula(
					paste(
						"dissMat() ~ . + Condition(",
							paste(
								'transCondData()[,"', 
								sapply(input$whichCondVars, FUN = paste0),
								'"]',
								sep = "",
								collapse = " + "
								),
						")"
						)
					),
				data = transExpData(),
				comm = transData(),
				add = input$correctionMethod2
				
			)
		}
		
	}) # End dbrda definition
 
# Test significance of model
anova <- reactive({
	
	if(is.null(input$dataset) | is.null(input$explanatoryVars))
		return()
	
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
		
		if(is.null(input$dataset) | is.null(input$explanatoryVars))
			return()
		
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


# Pring dbrda summary
	output$print <- renderPrint({
		
		if(is.null(input$dataset) | is.null(input$explanatoryVars))
			print("Please upload data")
		
		print(summary(dbrda()))
	})

# Print results of anova.cca()
	output$printSig <- renderPrint({
		
		if(is.null(input$dataset) | is.null(input$explanatoryVars))
			print("Please upload data")
			
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