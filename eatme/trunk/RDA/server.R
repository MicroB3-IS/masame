#runApp('C:\\Users\\pbuttigi\\Documents\\Revolution\\EATME\\RDA', launch.browser = FALSE)

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
#reactive ({
	#if (!is.null(conditioningFile())){
		output$whichCondVarsUI <- renderUI({
				checkboxGroupInput(
					inputId = "whichCondVars", 
					label = "Select at least one of your conditioning variables:",
					choices = names(conditioningFile()),
					selected = names(conditioningFile())
					)
		})
	#}
#})

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
	
		if (input$transform == 'none'){
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
	
		if (input$expTransform == 'none'){
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
	
		if (input$condTransform == 'none'){
			transCondData <- conditioningFile()
		} else {
			decostand(
				conditioningFile(),
				method = input$condTransform,
			)
		}
			
	})


# TODO: Priority: nice to have
# Add textInput to ui allowing users to select columns of the explanatoryFile
	
	rdaSol <- reactive({ 
		if (is.null(transCondData()) | is.null(input$whichCondVars) ){
			rda(
				formula = transData() ~ .,
 				data = transExpData(),
 				scale = input$scaleVars
				)
		} else {
			rda(
				formula = as.formula(
				paste(
					"transData() ~ . + Condition(",
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
 				scale = input$scaleVars
				)
		
		}
	})

# Test significance of model
anova <- reactive({
	if(is.null(strataFile())){
 			anova.cca(
				rdaSol()
				)
	} else {
 			anova.cca(
				rdaSol(),
				strata = strataFile()
				)
		}
	})


# Prepare output

	output$plot <- renderPlot({
		
		if (input$display == "both") {
		ordiplot(
			rdaSol(),
 			type = input$labels,
			scaling = as.numeric(input$scaling),
			col = c("red", "blue")
			)
		} else {
		ordiplot(
			rdaSol(),
 			type = input$labels,
			scaling = as.numeric(input$scaling),
			col = c("red", "blue"),
			display = input$display
			)	
		}
	})


	output$print <- renderPrint({
		print(summary(rdaSol()))
		})

	output$printSig <- renderPrint({
		print(anova())
		})


# Prepare downloads

	output$downloadData.plot <- downloadHandler(
	  filename <- function() {
		paste('RDA_plot-', Sys.Date(), '.tiff', sep='')
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
			
		if (input$display == "both") {
		ordiplot(
			rdaSol(),
 			type = input$labels,
			scaling = as.numeric(input$scaling),
			col = c("red", "blue")
			)
		} else {
		ordiplot(
			rdaSol(),
 			type = input$labels,
			scaling = as.numeric(input$scaling),
			col = c("red", "blue"),
			display = input$display
			)	
		}
			
		dev.off()
	  },
	  contentType = 'image/png'
	)

# Download object coordinates
	output$downloadData.objectCoordinates <- downloadHandler(
	  filename <- function() {
		paste('Object_coordinates-', Sys.Date(), '.csv', sep='')
	  },
	  content <- function(file) {
		write.csv(rdaSol()$CA$u, file)
	  },
	  contentType = 'text/csv'
	)

# Download variable coordinates
output$downloadData.variableCoordinates <- downloadHandler(
	  filename <- function() {
		paste('Variable_coordinates-', Sys.Date(), '.csv', sep='')
	  },
	  content <- function(file) {
		write.csv(rdaSol()$CA$v, file)
	  },
	  contentType = 'text/csv'
	)
		
	}) # End shiny server