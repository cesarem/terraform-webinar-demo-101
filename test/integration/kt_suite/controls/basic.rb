# frozen_string_literal: true
require 'awspec'
require 'rhcl'

main_tf = Rhcl.parse(File.open('variables.tf'))
#test_tf = Rhcl.parse(File.open('./test/fixtures/tf_module/main.tf'))

bucket_name = main_tf['variable']['bucket_name']['default']

control "file1_check" do
    describe file('./test/fixtures/tf_module/test1.txt') do
        it { should exist }
    end
end

control "file2_check" do
    describe file('./test/fixtures/tf_module/test2.txt') do
        it { should exist }
    end
end

control "check_s3_bucket" do
    describe s3_bucket(bucket_name) do
        it { should exist }
        #it { should have_object(file_1_name) }
        #it { should have_object(file_2_name) }
    end
end