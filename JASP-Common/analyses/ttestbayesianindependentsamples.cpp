#include "ttestbayesianindependentsamples.h"

#include "options/options.h"
#include "options/option.h"
#include "options/optionvariable.h"
#include "options/optionvariables.h"
#include "options/optionboolean.h"
#include "options/optioninteger.h"
#include "options/optionintegerarray.h"
#include "options/optionlist.h"
#include "options/optionnumber.h"

using namespace std;

TTestBayesianIndependentSamples::TTestBayesianIndependentSamples(int id)
	: Analysis(id, "TTestBayesianIndependentSamples", createOptions())
{
}

Options *TTestBayesianIndependentSamples::createOptions() const
{
	Options *options = new Options();

	options->add("variables", new OptionVariables());
	options->add("groupingVariable", new OptionVariable());

	options->add("descriptives", new OptionBoolean());

	options->add("hypothesis", new OptionList(list("groupsNotEqual", "groupOneGreater", "groupTwoGreater")));
	options->add("missingValues", new OptionList(list("excludeAnalysisByAnalysis", "excludeListwise")));

	options->add("priorWidth", new OptionNumber(1));

	options->add("plots", new OptionBoolean());
	options->add("plotWidth", new OptionInteger(320));
	options->add("plotHeight", new OptionInteger(240));

	options->add("bayesFactorType", new OptionList(list("BF10", "BF01")));

	return options;
}

