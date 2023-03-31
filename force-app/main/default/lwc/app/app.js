import { LightningElement, api, track, wire } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateOrdonnanceAboutRating from '@salesforce/apex/AP01_Ordonnance.updateOrdonnanceAboutRating';
import updateOrdonnanceAboutChoiceOfRating from '@salesforce/apex/AP01_Ordonnance.updateOrdonnanceAboutChoiceOfRating';
import getRatingById from '@salesforce/apex/AP01_Ordonnance.getRatingById';

export default class App extends LightningElement {

    _labelText = 'Notez l\'ordonnance : ';
    _numberOfStars = 5;
    changeStars = true;
    @track rating;
    @track alreadyChoice = false;
    ratingTmp = 0;
    @track isStatusClose = false;
    ratingFirst = 0;
    valueCheckbox = [];
    autreCheck = false;
    valueAutre = '';
    btnClose = false;
    id = '';
    @api recordId;
    // _valueRating = null;

    @track thereIsError = false;
    @track error = '';
    @track isModalOpen = false;

    @wire(getRatingById, {ordonnanceId: '$recordId'})
    wiredGetRatingById({ error, data }) {
        // console.log(data);
        if (data) {
            const ratingBdd = data.Rating__c;
            this.rating = ratingBdd;
            this.ratingTmp = ratingBdd;
            //this.isStatusClose = true;
             if (data.Statut__c === 'Expédiée' || data.Statut__c ===  'Reçue') this.isStatusClose = true;
            //this.ratingFirst = data;
            if (data.Rating__c > 0) {
                this.changeStars = false;
                this.alreadyChoice = true;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.rating = 0;
        }
    }

    get labelText() {
        return this._labelText;
    }

    @api
    set labelText(value) {
        this._labelText = value || "";
    }

    get numberOfStars() {
        return this._numberOfStars;
    }

    @api
    set numberOfStars(value) {
        this._numberOfStars = value;
    }

    showErrorToast(error = this.error) {
        const evt = new ShowToastEvent({
            title: 'Erreur lors la notation',
            message: error,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToast(value = this.rating) {
        const evt = new ShowToastEvent({
            title: 'Notation pris en compte',
            message: 'Votre notation concernant les ' + value + ' étoile(s) a bien été pris en compte, appuyez sur modifier la note si vous voulez réinistialiser votre choix !',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    get options() {
        return [
            {
                label: 'Adaptation',
                value: 'Adaptation',
            },
            {
                label: 'Teinte',
                value: 'Teinte',
            },
            {
                label: 'Occlusion',
                value: 'Occlusion',
            },
            {
                label: 'Esthétique',
                value: 'Esthetique',
            },
            {
                label: 'Délai non respecté',
                value: 'Délai non respecté',
            },
            {
                label: "Instruction non pris en compte",
                value: 'Instruction non pris en compte',
            },
            {
                label: "Autre",
                value: 'Autre',
            },
        ]
    }

    handleChangeCheckBox = (e) => {
        this.valueCheckbox  = e.detail.value;
        if (this.valueCheckbox.indexOf('Autre') !== -1) {
            this.autreCheck = true;
        }
        else {
            this.autreCheck = false;
        }
    }

    handleChangeAutre = (e) => {
        this.valueAutre = e.target.value;
    }

    closeModal() {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = false;
        if (this.valueCheckbox.length == 0) {
            this.thereIsError = true;
            this.error = "Votre notation " + this.ratingTmp + " étoile(s) n'a pas été pris en compte car vous n'avez pas choisi la raison !";
            this.showErrorToast();
            setTimeout(() => {
                this.thereIsError = false;
                this.error = '';
                this.rating = 0;
                this.ratingTmp = 0;
            }, 2000);
        }
    }

    onStarRatingClick(event){
        console.log('a');
        
        const { rating } = event.detail;

        if (this.rating > 0 && (this.rating == this.ratingTmp)) {
            this.changeStars = false;
        }

        if (rating == this._numberOfStars && this.changeStars) {
            updateOrdonnanceAboutRating({ordonnanceId: this.recordId, rate: rating, maxRate: this._numberOfStars})
            .then(res => {
                this.showSuccessToast(rating);
            })
        }
    
        if (rating < this._numberOfStars) {
            if (this.changeStars == false) {
                this.showErrorToast('Vous avez déjà donné votre avis, appuyez sur modifier la note si vous voulez réinistialiser votre choix !');
            }
            else {
                this.changeStars = true;
                this.ratingTmp = rating;
                this.isModalOpen = true;
            }
        }
        
    }

    handleClickModifier = (e) => {
        this.changeStars = true;
        this.alreadyChoice = false;
        this.rating = 0;
        this.valueAutre = '';
        this.valueCheckbox = [];
    }

    submit = (e) => {
        this.closeModal();
        if (!this.thereIsError) {
            updateOrdonnanceAboutRating({ordonnanceId: this.recordId, rate: this.ratingTmp, maxRate: this._numberOfStars})
            .then(res => {
                updateOrdonnanceAboutChoiceOfRating({ ordonnanceId: this.recordId, choices: this.valueCheckbox.join(';'), other: this.valueAutre})
                .then(res => {
                    this.changeStars = false;
                    this.alreadyChoice = true;
                    this.rating = this.ratingTmp;
                    this.showSuccessToast();
                })
                .catch(err => {
                    this.showErrorToast();
                    console.log(err)
                })
            })
            .catch(err => {
                this.showErrorToast();
                console.log(err)
            });
        }
    }
}