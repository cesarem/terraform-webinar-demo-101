lb_url         = attribute('lb_url', description: 'load balancer url')
url_file1      = attribute('url_file1', description: 'test1.txt file url')
url_file2      = attribute('url_file2', description: 'test2.txt file url')
file_timestamp = attribute('file_timestamp', description: 'file time stamp') 

control 'http_requests' do
  desc "Firt attempt could fail because the resource has been recently created"
  
  describe.one do
    describe http(lb_url) do
      its('status') { should cmp 200 }
    end
    describe http(lb_url) do
      its('status') { should cmp 200 }
    end
    describe http(lb_url) do
      its('status') { should cmp 200 }
    end
  end
  
  describe.one do
    describe http(url_file1) do
      its('status') { should cmp 200 }
      its('body') { should cmp file_timestamp }
    end
    describe http(url_file1) do
      its('status') { should cmp 200 }
      its('body') { should cmp file_timestamp }
    end
  end
  describe.one do
    describe http(url_file2) do
      its('status') { should cmp 200 }
      its('body') { should cmp file_timestamp }
    end
    describe http(url_file2) do
      its('status') { should cmp 200 }
      its('body') { should cmp file_timestamp }
    end
  end
end