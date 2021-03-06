require 'test_plugin_helper'

describe JobTemplateImporter do
  context 'importing a new template' do
    # JobTemplate tests handle most of this, we just check that the shim
    # correctly loads a template returns a hash
    let(:remote_execution_feature) do
      FactoryGirl.create(:remote_execution_feature)
    end

    let(:result) do
      name = "Community Service Restart"
      text = <<-END_TEMPLATE
<%#
model: JobTemplateImporter
kind: job_template
name: Service Restart
job_category: Service Restart
provider_type: SSH
feature: #{remote_execution_feature.label}
template_inputs:
- name: service_name
  input_type: user
  required: true
- name: verbose
  input_type: user
%>

service <%= input("service_name") %> restart
END_TEMPLATE

      # This parameter is unused but foreman_templates will supply it
      # so we test it's accepted
      metadata = "unused"

      JobTemplateImporter.import!(name, text, metadata)
    end

    let(:template) { JobTemplate.find_by_name 'Community Service Restart' }

    it 'returns a valid foreman_templates hash' do
      result[:status].must_equal true
      result[:result].must_equal '  Created Template :Community Service Restart'
      result[:old].must_equal nil
      result[:new].must_equal template.template.squish
    end
  end
end
