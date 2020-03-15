# frozen_string_literal: true

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