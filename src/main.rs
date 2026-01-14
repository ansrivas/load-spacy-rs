use pyo3::prelude::*;

fn main() -> PyResult<()> {
    Python::attach(|py| {
        let spacy = py.import("spacy")?;
        let nlp = spacy.call_method1("load", ("de_core_news_sm",))?;

        let doc = nlp.call1(("Die Häuser stehen am Fluss.",))?;

        for token in doc.try_iter()? {
            let token = token?;
            let text: String = token.getattr("text")?.extract()?;
            let lemma: String = token.getattr("lemma_")?.extract()?;
            println!("{text} → {lemma}");
        }

        Ok(())
    })
}