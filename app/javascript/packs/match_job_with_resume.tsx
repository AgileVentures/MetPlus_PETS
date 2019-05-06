import * as React from 'react'
import * as ReactDOM from 'react-dom'
import Modal from 'react-modal'
import Parser from 'html-react-parser'
import axios, { AxiosResponse } from 'axios'
import { Notifications } from './notifications'

const customStyles = {
  content: {
    top: '50%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translate(-50%, -50%)'
  }
}

export interface ResultObserver<SomeData> {
  success (response: SomeData)

  error (errorMessage: ErrorMessage)
}

export function GetStars (jobId: string, jobSeekerId: string, observer: ResultObserver<Data>) {
  axios.get(`/jobs/${jobId}/match_resume`, {
    params: {
      job_seeker_id: jobSeekerId
    },
    headers: { 'X-Requested-With': 'XMLHttpRequest' }
  }).then((response: AxiosResponse<Data>) => {
    observer.success(response.data)
  }).catch((response: AxiosResponse<ErrorMessage>) => {
    observer.error(response.data)
  })
}

export interface MatchJobWithResumePropTypes {
  jobId: string
  jobSeekerId: string

  getStars (jobId: string, jobSeekerId: string, observer: ResultObserver<Data>)
}

export interface Data {
  stars_html: string
}

export interface ErrorMessage {
  message: string
}

export class MatchJobWithResume extends React.Component<MatchJobWithResumePropTypes> {
  state = { modalIsOpen: false, modalText: '' }

  constructor (props) {
    super(props)

    this.openModal = this.openModal.bind(this)
    this.closeModal = this.closeModal.bind(this)
  }

  openModal () {
    const answer = window.confirm('This will match your résumé against all active jobs ' +
            'and may take a while.     Do you want to proceed?')
    if (answer) {
      const component = this
      this.props.getStars(this.props.jobId, this.props.jobSeekerId, {
        error (errorMessage: ErrorMessage) {
          if (errorMessage === undefined) {
            Notifications.errorNotification('Unable to contact the cruncher')
          } else {
            Notifications.errorNotification(errorMessage.message)
          }
        },
        success (data: Data) {
          component.setState({ modalIsOpen: true, modalText: data.stars_html })
        }
      })
    }
  }

  closeModal () {
    this.setState({ modalIsOpen: false })
  }

  render () {
    return (
        <div>
          <MainButton id='match_my_resume' text='Match against my Résumé' onClick={this.openModal} />
          <Modal
            isOpen={this.state.modalIsOpen}
            onRequestClose={this.closeModal}
            style={customStyles}
            contentLabel='Match against my Résumé'
            ariaHideApp={false}
          >
            <div>
              <button className='close' data-dismiss='modal' type='button'>
                <span aria-hidden='true' onClick={this.closeModal}>×</span>
              </button>
              <h4 className='modal-title text-center'>
                            Job match against your résumé
              </h4>
            </div>
            <div className='modal-body text-center'>
              <div className='fa-lg' id='resumeMatchScore'>
                {Parser(this.state.modalText)}
              </div>
            </div>
            <div className='modal-footer'>
              <button className='btn btn-default' onClick={this.closeModal} type='button'>Close</button>
            </div>
          </Modal>
        </div>
    )
  }
}

interface MainButtonProps {
  id: string
  text: string

  onClick (): void
}

const MainButton: React.FunctionComponent<MainButtonProps> = (props) => (
  <div>
    <a id={props.id} className='btn btn-primary' onClick={props.onClick}>
      {props.text}
    </a>
  </div>
)

document.addEventListener('turbolinks:load', () => {
  const node = document.getElementById('resume-data')
  if (node != null) {
    ReactDOM.render(
      <MatchJobWithResume jobId={node.dataset['jobId']} jobSeekerId={node.dataset['jobSeekerId']}
        getStars={GetStars} />,
      document.getElementById('match-resume-button').appendChild(document.createElement('div'))
    )
  }
})
