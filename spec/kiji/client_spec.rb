require 'spec_helper'

describe Kiji::Client do
  before do
    cert_file        = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.cer')
    private_key_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'e-GovEE02_sha2.pem')

    @cert = OpenSSL::X509::Certificate.new(File.read(cert_file))
    @private_key =  OpenSSL::PKey::RSA.new(File.read(private_key_file), 'gpkitest')
  end

  describe '#initialize' do
    it 'is able to set attributes in block' do
      @client = Kiji::Client.new do |c|
        c.software_id = 'my_software_id'
        c.api_end_point = 'my_api_end_point'
        c.basic_auth_id = 'my_basic_auth_id'
        c.basic_auth_password = 'my_basic_auth_password'
        c.cert = @cert
        c.private_key = @private_key
      end
      expect(@client.software_id).to eq 'my_software_id'
      expect(@client.api_end_point).to eq 'my_api_end_point'
      expect(@client.basic_auth_id).to eq 'my_basic_auth_id'
      expect(@client.basic_auth_password).to eq 'my_basic_auth_password'
      expect(@client.cert).to eq @cert
      expect(@client.private_key).to eq @private_key
    end

    it 'is able to set attributes after init' do
      @client = Kiji::Client.new
      @client.software_id = 'my_software_id'
      @client.api_end_point = 'my_api_end_point'
      @client.basic_auth_id = 'my_basic_auth_id'
      @client.basic_auth_password = 'my_basic_auth_password'
      @client.cert = @cert
      @client.private_key = @private_key

      expect(@client.software_id).to eq 'my_software_id'
      expect(@client.api_end_point).to eq 'my_api_end_point'
      expect(@client.basic_auth_id).to eq 'my_basic_auth_id'
      expect(@client.basic_auth_password).to eq 'my_basic_auth_password'
      expect(@client.cert).to eq @cert
      expect(@client.private_key).to eq @private_key
    end

    # it '一括送信用構成管理XMLファイルのビルド1' do
    #   appl_data = Nokogiri::XML(File.read('tmp/build_test/base_kousei.xml'))
    #   doc = appl_data.to_xml(save_with:  0)
    #   signer = Kiji::Signer.new(doc) do |s|
    #     s.cert =  OpenSSL::X509::Certificate.new(File.read('tmp/build_test/ikkatsu.cer'))
    #     s.private_key = OpenSSL::PKey::RSA.new(File.read('tmp/build_test/ikkatsu.pem'), 'hoge')
    #     s.digest_algorithm           = :sha256
    #     s.signature_digest_algorithm = :sha256
    #   end
    #   signer.security_node = signer.document.root
    #   node = signer.document.at_xpath('//構成情報')
    #   signer.digest!(node, id: '#構成情報')
    #
    #   app_doc = File.read('tmp/bulk_apply/4950000020325000(1)/495000020325029841_01.xml')
    #   signer.digest_file!(app_doc, id: '495000020325029841_01.xml')
    #
    #   signer.sign!(issuer_serial: true)
    #
    #   signer.document.xpath('//ns:Signature', ns: 'http://www.w3.org/2000/09/xmldsig#').wrap('<署名情報></署名情報>')
    # File.write('tmp/bulk_apply/4950000020325000(1)/kousei.xml', Nokogiri::XML(signer.to_xml))
    #
    #   directory_to_zip = 'tmp/bulk_apply'
    #   output_file = 'tmp/bulk_apply.zip'
    #   zf = ZipFileGenerator.new(directory_to_zip, output_file)
    #   zf.write
    # end

    it '一括送信用構成管理XMLファイルのビルド(bulk_apply_for_api.zip)' do
      appl_data = Nokogiri::XML(File.read('tmp/base_kousei_files/900A010200001000_base_kousei.xml'))
      doc = appl_data.to_xml(save_with:  0)
      signer = Kiji::Signer.new(doc) do |s|
        s.cert =  @cert
        s.private_key = @private_key
        s.digest_algorithm           = :sha256
        s.signature_digest_algorithm = :sha256
      end
      signer.security_node = signer.document.root
      node = signer.document.at_xpath('//構成情報')
      signer.digest!(node, id: '#構成情報')

      app_doc = File.read('tmp/bulk_apply_for_api/900A010200001000(1)/900A01020000100001_01.xml')
      signer.digest_file!(app_doc, id: '900A01020000100001_01.xml')

      signer.sign!(issuer_serial: true)

      signer.document.xpath('//ns:Signature', ns: 'http://www.w3.org/2000/09/xmldsig#').wrap('<署名情報></署名情報>')
      File.write('tmp/bulk_apply_for_api/900A010200001000(1)/kousei.xml', Nokogiri::XML(signer.to_xml))

      directory_to_zip = 'tmp/bulk_apply_for_api'
      output_file = 'tmp/bulk_apply_for_api.zip'
      zf = ZipFileGenerator.new(directory_to_zip, output_file)
      zf.write
    end
  end
end
