# frozen_string_literal: true

#require 'kitchen-terraform'
#require 'kitchen-verifier-awspec'
require 'awspec'
require 'rhcl'

main_tf = Rhcl.parse(File.open('variables.tf'))
#test_tf = Rhcl.parse(File.open('main.tf'))

bucket_name = main_tf['variable']['bucket_name']['default']
#file_1_name = test_tf['resource']['aws_s3_bucket_object']['object_1']['key']
#file_2_name = test_tf['resource']['aws_s3_bucket_object']['object_2']['key']

describe s3_bucket(bucket_name) do
  it { should exist }
  #it { should have_object(file_1_name) }
  #it { should have_object(file_2_name) }
end
