
ind.rep <- function (i, p) 
{
  (1:(p + 1)) + (i - 1) * (p + 1)
}

#estimate elementary effect on Morris
ee.oat <-function (X, y) 
{
  p <- ncol(X)
  r <- nrow(X)/(p + 1)
  ee <- matrix(nrow = r, ncol = p)
  colnames(ee) <- colnames(X)
  for (i in 1:r) {
    j <- ind.rep(i, p)
    j1 <- j[1:p]
    j2 <- j[2:(p + 1)]
    ee[i, ] <- solve(X[j2, ] - X[j1, ], y[j2] - y[j1])
  }
  return(ee)
}

#estimate morris mu7
estim_morris_mu <- function (data, i=1:nrow(data))
{
  d <- data[i, ]  #allow boot to select origianl indices
  mu_abs=apply(d, 2, function(x) mean(abs(x))) #mu7star
  
  return(mu_abs)
}

#estimate morris sigma
estim_morris_sig <- function (data, i=1:nrow(data))
{
  d <- data[i, ] #allow boot to select origianl indices
  
  sig=apply(d, 2, sd) 
  return(sig)
}

#boot stats for morris
b.stats.morris <- function (b, conf = 0.95, type = "norm") 
{
  p <- length(b$t0)
  lab <- c("original", "bias", "std. error", "min. c.i.", "max. c.i.")
  out <- as.data.frame(matrix(nrow = p, ncol = length(lab), 
                              dimnames = list(NULL, lab)))
  for (i in 1:p) {
    out[i, "original"] <- b$t0[i]
    out[i, "bias"] <- mean(b$t[, i]) - b$t0[i]
    out[i, "std. error"] <- sd(b$t[, i])
    if (type == "norm") {
      ci <- boot.ci(b, index = i, type = "norm", conf = conf)
      if (!is.null(ci)) {
        out[i, "min. c.i."] <- ci$norm[2]
        out[i, "max. c.i."] <- ci$norm[3]
      }
    }
    else if (type == "basic") {
      ci <- boot.ci(b, index = i, type = "basic", conf = conf)
      if (!is.null(ci)) {
        out[i, "min. c.i."] <- ci$basic[4]
        out[i, "max. c.i."] <- ci$basic[5]
      }
    }
  }
  return(out)
}

