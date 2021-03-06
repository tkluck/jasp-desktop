
TTestPairedSamples <- function(dataset=NULL, options, perform="run", callback=function(...) 0, ...) {

	all.variables <- unique(unlist(options$pairs))
	all.variables <- all.variables[all.variables != ""]

	if (is.null(dataset))
	{
		if (perform == "run") {
		
			if (options$missingValues == "excludeListwise") {
			
				dataset <- .readDataSetToEnd(columns.as.numeric=all.variables, exclude.na.listwise=all.variables)
			}
			else {
			
				dataset <- .readDataSetToEnd(columns.as.numeric=all.variables)
			}
			
		} else {
		
			dataset <- .readDataSetHeader(columns.as.numeric=all.variables)
		}
	}

	results <- list()
	
	
	meta <- list()
	
	meta[[1]] <- list(name="ttest", type="table")
	meta[[2]] <- list(name="descriptives", type="table")
	
	results[[".meta"]] <- meta
	
	

	ttest <- list()
	
	if (options$hypothesis == "groupsNotEqual") {
	
		ttest[["title"]] <- "Paired Samples T-Test"
	}
	else {
	
		ttest[["title"]] <- "One Tailed Paired Samples T-Test"
	}

	fields <- list(
		list(name=".variable1", type="string", title=""),
		list(name=".separator", type="string", title=""),
		list(name=".variable2", type="string", title=""),
		list(name="t", type="number", format="sf:4;dp:3"),
		list(name="df", type="number", format="sf:4;dp:3"),
		list(name="p", type="number", format="dp:3;p:.001"))

	if(options$meanDifference){
		fields[[length(fields)+1]] <- list(name="mean difference", type="number", format="sf:4;dp:3")
	}
	
	if(options$effectSize){
		fields[[length(fields)+1]] <- list(name="Cohen's d", type="number", format="sf:4;dp:3")
	}
	
	if(options$confidenceInterval){
		fields[[length(fields)+1]] <- list(name="lower", type="number", format="sf:4;dp:3")
		fields[[length(fields)+1]] <- list(name="upper", type="number", format="sf:4;dp:3")
	}

	ttest[["schema"]] <- list(fields=fields)

	ttest.results <- list()
	
	for (pair in options$pairs)
	{
		row <- list(.variable1=pair[[1]], .separator="-", .variable2=pair[[2]])
		
		if (perform == "run") {
		
			if (pair[[1]] != "" && pair[[2]] != "") {

				c1 <- dataset[[ .v(pair[[1]]) ]]
				c2 <- dataset[[ .v(pair[[2]]) ]]
			
				ci <- options$confidenceIntervalInterval
			
				if (options$hypothesis == "groupsNotEqual")
					tail <- "two.sided"
				if (options$hypothesis == "groupOneGreater")
					tail <- "greater"
				if (options$hypothesis == "groupTwoGreater")
					tail <- "less"
	
				r <- t.test(c1, c2, paired = TRUE, conf.level = ci, alternative = tail)
			
				t  <- .clean(as.numeric(r$statistic))
				df <- as.numeric(r$parameter)
				p  <- as.numeric(r$p.value)
				m  <- as.numeric(r$estimate)
				es <- .clean((mean(c1)-mean(c2))/(sqrt((sd(c1)^2+sd(c2)^2)/2)))
			
				ci.l <- as.numeric(r$conf.int[1])
				ci.u <- as.numeric(r$conf.int[2])
			
				if (options$hypothesis == "groupOneGreater")
					ci.u = .clean(Inf)
				if (options$hypothesis == "groupTwoGreater")
					ci.l = .clean(-Inf)				
			}
			else {
			
				t  <- ""
				df <- ""
				p  <- ""
				m  <- ""
				es <- ""
			
				ci.l <- ""
				ci.u <- ""
			}
			
			row[["t"]]  <- t
			row[["df"]] <- df
			row[["p"]]  <- p
			
			if (options$meanDifference) {
			
				row[["mean difference"]] <- m
			}
			
			if (options$effectSize) {
			
				row[["Cohen's d"]] <- es
			}
			
			if(options$confidenceInterval) {
			
				row[["lower"]] <- ci.l
				row[["upper"]] <- ci.u
			}
		}
		
		ttest.results[[length(ttest.results)+1]] <- row
	}
	
	ttest[["data"]] <- ttest.results


	if (options$descriptives) {
	
		descriptives <- list()

		descriptives[["title"]] <- "Descriptives"

		fields <- list(
			list(name=".variable", type="string", title=""),
			list(name="N", type="number", format="sf:4;dp:3"),
			list(name="mean", type="number", format="sf:4;dp:3"),
			list(name="sd", type="number", format="dp:3;p:.001"),
			list(name="SE", type="number", format="dp:3;p:.001"))

		descriptives[["schema"]] <- list(fields=fields)
		
		descriptives.results <- list()
		
		desc.vars <- unique(unlist(options$pairs))
		desc.vars <- desc.vars[desc.vars != ""]
		
		for (var in desc.vars) {
		
			row <- list(.variable=var)

			if (perform == "run") {
				
				n   <- .clean(as.numeric(length(dataset[[ .v(var) ]])))
				m   <- .clean(as.numeric(  mean(dataset[[ .v(var) ]], na.rm = TRUE)))
				std <- .clean(as.numeric(    sd(dataset[[ .v(var) ]], na.rm = TRUE)))
				
				if (is.numeric(std)) {
					se <- .clean(as.numeric(std/sqrt(n)))}
				else
					se <- "NaN"
					
				row[["N"]] <- n
				row[["mean"]] <- m
				row[["sd"]] <- std
				row[["SE"]] <- se
			
			}
			
			descriptives.results[[length(descriptives.results)+1]] <- row
		}
		
		descriptives[["data"]] <- descriptives.results

		results[["descriptives"]] <- descriptives
	}
	
	results[["ttest"]] <- ttest
	
		
	results
}

