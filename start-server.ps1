# EQUITY Finance App – PowerShell HTTP Server
# Run: powershell -ExecutionPolicy Bypass -File start-server.ps1

$port = 3000
$dir  = $PSScriptRoot

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Write-Host ""
Write-Host "  ✅  EQUITY Finance App running at http://localhost:$port" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop." -ForegroundColor Gray
Write-Host ""

# Open browser automatically
Start-Process "http://localhost:$port"

$mime = @{
    ".html" = "text/html; charset=utf-8"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".json" = "application/json"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
}

try {
    while ($listener.IsListening) {
        $ctx  = $listener.GetContext()
        $req  = $ctx.Request
        $resp = $ctx.Response

        $path = $req.Url.LocalPath
        if ($path -eq "/") { $path = "/index.html" }
        $file = Join-Path $dir $path.TrimStart("/")

        if (Test-Path $file -PathType Leaf) {
            $ext  = [System.IO.Path]::GetExtension($file)
            $ct   = if ($mime[$ext]) { $mime[$ext] } else { "text/plain" }
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $resp.ContentType   = $ct
            $resp.ContentLength64 = $bytes.Length
            $resp.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $resp.StatusCode = 404
            $body = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $resp.OutputStream.Write($body, 0, $body.Length)
        }
        $resp.OutputStream.Close()
    }
} finally {
    $listener.Stop()
}
