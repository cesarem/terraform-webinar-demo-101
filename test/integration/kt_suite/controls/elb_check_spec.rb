control 'elb_check' do
  aws_elbs.each do |elb|
    describe elb do
      its('external_ports.count') { should cmp 1 }
      its('external_ports')       { should include 80 }
      its('internal_ports.count') { should cmp 1 }
      its('internal_ports')       { should include 80 }
    end
  end
end