# frozen_string_literal: true

describe Phlex::HTML do
	extend ViewHelper

	with "hash attributes" do
		view do
			def template
				div data: { name: { first_name: "Joel" } }
			end
		end

		it "flattens the attributes" do
			expect(output).to be == %(<div data-name-first-name="Joel"></div>)
		end
	end

	with "string keyed hash attributes" do
		view do
			def template
				div data: { "name_first_name" => "Joel" }
			end
		end

		it "flattens the attributes without dasherizing them" do
			expect(output).to be == %(<div data-name_first_name="Joel"></div>)
		end
	end
	
	with "resolve_attributes hook defined" do
		view do
			def resolve_attributes(turbo: false, **rest)
				rest.merge!(data_turbo: "true", data_turbo_stream: true) if turbo
				rest
			end
			
			def template
				div turbo: true
			end
		end
		
		it "uses the resolved attributes" do
			expect(output).to be == %(<div data-turbo="true" data-turbo-stream></div>)
		end
	end

	if RUBY_ENGINE == "ruby"
		with "unique tag attributes" do
			view do
				def template
					div class: SecureRandom.hex
				end
			end

			let :report do
				view.new.call

				MemoryProfiler.report do
					2.times { view.new.call }
				end
			end

			it "doesn't leak memory" do
				expect(report.total_retained).to be == 0
			end
		end
	end
end
