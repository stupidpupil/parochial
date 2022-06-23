download_timeout_in_seconds <- function(size_in_bytes, bandwidth_in_mbps = 10){
	bandwidth_in_bytes_per_second <- bandwidth_in_mbps * 1000 * 1000 / 8

	ret <- (size_in_bytes * 1.1) / (bandwidth_in_bytes_per_second * 0.8)

	ret <- 30*ceiling(ret/30)

	max(ret, 120, options()$timeout)
}

