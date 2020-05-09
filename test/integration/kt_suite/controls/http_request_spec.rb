control 'operating_system' do
  describe http('http://localhost') do
  its('status') { should cmp 200 }
    end
end