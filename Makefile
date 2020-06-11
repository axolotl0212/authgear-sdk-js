REF := $(shell git describe --all --exact-match | sed -e "s|^heads/||")

# The documentation build pipeline works in the following way.
#
# 1. Generate individual .d.ts with tsc.
# 2. Generate rollup .d.ts with api-extractor.
# 3. Generate markdown files with typedoc and typedoc-plugin-markdown
# 4. Rewrite document ID.
# 5. Generate sidebars.js
.PHONY: docs
docs:
	rm -rf ./temp/
	mkdir -p ./temp/docs
	npm run dts
	npx typedoc \
		--options typedoc/typedoc.json \
		--tsconfig typedoc/tsconfig.web.json \
		--name @skygear/web \
		--inputFiles packages/skygear-web/index.d.ts \
		--out ./temp/docs/web \
		--theme docusaurus2 \
		--skipSidebar \
		--namedAnchors \
		--hideSources
	npx typedoc \
		--options typedoc/typedoc.json \
		--tsconfig typedoc/tsconfig.react-native.json \
		--name @skygear/react-native \
		--inputFiles packages/skygear-react-native/index.d.ts \
		--out ./temp/docs/react-native \
		--theme docusaurus2 \
		--namedAnchors \
		--hideSources
	cp ./typedoc/index.md ./temp/docs/index.md
	./scripts/rewrite_document_id.py ./temp/docs
	./scripts/generate_sidebars_js.py ./temp/docs >./temp/sidebars.js
	rm -rf ./website/docs
	cp -R ./temp/docs/. ./website/docs
	cp ./temp/sidebars.js ./website
	(cd website && yarn build)

.PHONY: deploy-docs
deploy-docs: docs
	./scripts/deploy_docs.sh
