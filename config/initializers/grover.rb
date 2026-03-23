Grover.configure do |config|
  config.options = {
    format: "A4",
    margin: {
      top: "12mm",
      bottom: "12mm",
      left: "12mm",
      right: "12mm"
    },
    print_background: true,
    prefer_css_page_size: true,
    launch_args: [ "--no-sandbox", "--disable-setuid-sandbox", "--disable-gpu" ],
    wait_until: "networkidle0"
  }
end
