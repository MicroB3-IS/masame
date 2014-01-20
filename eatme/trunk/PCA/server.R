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

# Perform PCA analysis
	pca <- reactive({ 
		rda(
			transData()
		)
	})

# Prepare output...

	output$plot <- renderPlot({
		biplot(
			pca(),
 			type = input$labels,
			scaling = as.numeric(input$scaling),
			col = c("red", "blue")
			)
	})

	output$eigenvals <- renderPrint({
		eigenvals(pca())
	})

	output$print <- renderPrint({
		print(pca())
	})

	output$objectScores <- renderPrint({
		print(pca()$CA$u.eig)
	})

	output$variableScores <- renderPrint({
		print(pca()$CA$v.eig)
	})

# Prepare downloads

output$downloadData.plot <- downloadHandler(
  filename <- function() {
    paste('PCA_plot-', Sys.Date(), '.tiff', sep='')
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
		
	biplot(
			pca(),
 			type = input$labels,
			scaling = as.numeric(input$scaling),
			col = c("red", "blue")
			)
		
	dev.off()
  },
  contentType = 'image/png'
)


output$downloadData.objectScores <- downloadHandler(
  filename <- function() {
    paste('Object_scores-', Sys.Date(), '.csv', sep='')
  },
  content <- function(file) {
    write.csv(pca()$CA$u.eig, file)
  },
  contentType = 'text/csv'
)

output$downloadData.variableScores <- downloadHandler(
  filename <- function() {
    paste('Variable_scores-', Sys.Date(), '.csv', sep='')
  },
  content <- function(file) {
    write.csv(pca()$CA$v.eig, file)
  },
  contentType = 'text/csv'
)
	
})